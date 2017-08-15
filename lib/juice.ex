defmodule Juice do
  def imagename, do: "nonis/baseimage"
  def testcases_src, do: "/home/nonis/testcases"
  def testcases_dst, do: "/testcases"
  def opt, do: [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]

  def headers do
    {:ok , hostname} = :inet.gethostname
    %{"Content-Type" => "application/json", "Host" => hostname}
  end

  defmodule Container do
    def create() do
      result = Dockerex.Client.post("containers/create", 
        %{"Image": Juice.imagename,
          "Tty": true,
          "HostConfig": %{
            "RestartPolicy": %{ "Name": "always"},
            "Binds": [
              Juice.testcases_src <> ":" <> Juice.testcases_dst #<> ":ro"
            ]
          }
        }, Juice.headers, Juice.opt)
      result["Id"]
    end

    def start(cid) do
      Dockerex.Client.post("containers/#{cid}/start", "", Juice.headers, Juice.opt)
      cid
    end

    def kill(cid) do
      Dockerex.Client.delete("containers/#{cid}?force=true", Juice.headers, Juice.opt)
      cid
    end
  end

  defmodule Exec do
    def create(cid, command) do
      exec = Dockerex.Client.post("containers/#{cid}/exec", 
        %{
          "AttachStdout": true,
          "AttachStderr": true,
          "Cmd": command,
          "DetachKeys": "ctrl-p,ctrl-q",
          "Privileged": true,
          "Tty": true,
          "User": "123:456"
        }, Juice.headers, Juice.opt)
      exec["Id"]
    end

    def start(eid) do
      Dockerex.Client.post("exec/#{eid}/start", 
        %{"Detach": false, "Tty": true}, Juice.headers, Juice.opt)
    end

    def test(cid, user_id, problem_id, test_id, language) do
      time1 = :os.system_time(:millisecond)
      output = Exec.create(cid, Juice.build_command(user_id, problem_id, test_id, language))
            |> Exec.start()
      time2 = :os.system_time(:millisecond)
      res = %{output: output, time: time2 - time1}
      # TODO need to pull stderr, and throw a {:error, msg} on any errors
      case output do
        _ ->
          {:success, res}
      end
    end
  end

  def infile(problem_id, test_id) do
    "/testcases/#{problem_id}/tests/i#{test_id}.txt"
  end

  def solfile(problem_id, test_id) do
    "/testcases/#{problem_id}/tests/o#{test_id}.txt"
  end

  def outfile(problem_id, test_id, user_id) do
    "#{Juice.testcases_dst}/#{problem_id}/#{user_id}/#{test_id}.txt"
  end

  def build_command(user_id, problem_id, test_id, language) do
    ["sh", "-c", 
      case language do
        "Java" ->
          entrypoint = "Main"
          infile = infile(problem_id, test_id)
          outfile = outfile(problem_id, test_id, user_id)
          "java -cp #{Juice.testcases_dst}/#{problem_id}/#{user_id} #{entrypoint} < #{infile} > #{outfile}; cat #{outfile}"
        _ ->
          raise "only java for now"
      end
    ]
  end

  def test(user_id, problem_id, test_id, language) do
    cid = Container.create()
       |> Container.start()

    given = %{
      user_id: user_id,
      problem_id: problem_id,
      test_id: test_id,
      language: language
    }

    {status, output} = Exec.test(cid, user_id, problem_id, test_id, language)
    if status == :error do
      IO.puts "killing container, error"
      Container.kill(cid)
      %{
        status: :failure,
        message: "failed running given code",
        given: given,
        result: output
      }
    end

    outfile = outfile(problem_id, test_id, user_id)
    solfile = solfile(problem_id, test_id)
    diff = Exec.create(cid, ["diff", "#{outfile}", "#{solfile}"])
        |> Exec.start()
    
    IO.puts "killing container"
    Container.kill(cid)

    %{
      result: output,
      given: given,
      diff: diff
    } |> Map.merge(
    case diff do
      nil ->
        %{
          status: :success,
          message: "success"
        }
      _ ->
        %{
          status: :failure,
          message: "output differed",
        }
    end)
  end

  def run(command) do
    cid = Container.create()
       |> Container.start()
    
    output = Exec.create(cid, command)
          |> Exec.start()

    cid |> Container.kill()

    output
  end
end

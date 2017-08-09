defmodule Juice do
  require MyConstants
  alias MyConstants, as: Const
  def headers do
    {:ok , hostname} = :inet.gethostname
    %{"Content-Type" => "application/json", "Host" => hostname}
  end

  defmodule Container do
    def create() do
      result = Dockerex.Client.post("containers/create", 
        %{"Image": Const.imagename,
          "Tty": true,
          "HostConfig": %{
            "RestartPolicy": %{ "Name": "always"},
            "Binds": [
              Const.testcases_src <> ":" <> Const.testcases_dst #<> ":ro"
            ]
          }
        }, Juice.headers, Const.opt)
      result["Id"]
    end

    def start(cid) do
      Dockerex.Client.post("containers/#{cid}/start", "", Juice.headers, Const.opt)
      cid
    end

    def kill(cid) do
      Dockerex.Client.post("containers/#{cid}/kill", "", Juice.headers, Const.opt)
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
        }, Juice.headers, Const.opt)
      exec["Id"]
    end

    def start(eid) do
      Dockerex.Client.post("exec/#{eid}/start", 
        %{"Detach": false, "Tty": true}, Juice.headers, Const.opt)
    end
  end

  def infile(problem_id, test_id) do
    "/testcases/#{problem_id}/tests/i#{test_id}.txt"
  end

  def solfile(problem_id, test_id) do
    "/testcases/#{problem_id}/tests/o#{test_id}.txt"
  end

  def outfile(problem_id, test_id, user_id) do
    "#{Const.testcases_dst}/#{problem_id}/#{user_id}/#{test_id}.txt"
  end

  def build_command(user_id, problem_id, test_id, language) do
    ["sh", "-c", 
      case language do
        "Java" ->
          entrypoint = "Main"
          infile = infile(problem_id, test_id)
          outfile = outfile(problem_id, test_id, user_id)
          "java -cp #{Const.testcases_dst}/#{problem_id}/#{user_id} #{entrypoint} < #{infile} > #{outfile}; cat #{outfile}"
        _ ->
          raise "only java for now"
      end
    ]
  end

  def test(user_id, problem_id, test_id, language) do
    cid = Container.create()
       |> Container.start()

    time1 = :os.system_time(:millisecond)
    output = Exec.create(cid, build_command(user_id, problem_id, test_id, language))
          |> Exec.start()
    time2 = :os.system_time(:millisecond)

    outfile = outfile(problem_id, test_id, user_id)
    solfile = solfile(problem_id, test_id)
    diff = Exec.create(cid, ["diff", "#{outfile}", "#{solfile}"])
          |> Exec.start()
    
    cid |> Container.kill()
    case output do
      nil ->
        %{
          status: "error",
          message: output
        }
      _ ->
        %{
          status: "success",
          output: output,
          diff: diff,
          time: time2 - time1
        }
    end
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

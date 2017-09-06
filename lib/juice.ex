defmodule Juice do
  def imagename, do: "nonis/baseimage"
  def testcases_src, do: "/home/nonis/testcases"
  def testcases_dst, do: "/testcases"
  def opt, do: [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]

  alias Docker.Client.Container, as: Container
  alias Docker.Client.Exec, as: Exec

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

defmodule Juice do
  alias Docker.Client.Container, as: Container
  alias Docker.Client.Exec, as: Exec

  def infile(problem_id, test_id) do
    "/testcases/#{problem_id}/tests/i#{test_id}.txt"
  end

  def solfile(problem_id, test_id) do
    "/testcases/#{problem_id}/tests/o#{test_id}.txt"
  end

  def outfile(problem_id, test_id, user_id) do
    "#{Docker.Client.testcases_dst}/#{problem_id}/#{user_id}/#{test_id}.txt"
  end

  def compile(user_id, problem_id, test_id, language) do 
    cid = Container.create()
       |> Container.start()

    cid |> Container.kill()
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

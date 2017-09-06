defmodule Docker.Client.Exec do
  def create(cid, command) do
    exec = Docker.Rest.post("containers/#{cid}/exec", 
      %{
        "AttachStdout": true,
        "AttachStderr": true,
        "Cmd": command,
        "DetachKeys": "ctrl-p,ctrl-q",
        "Privileged": true,
        "Tty": true,
        "User": "123:456"
      })
    exec["Id"]
  end

  def start(eid) do
    Docker.Rest.post("exec/#{eid}/start", 
      %{"Detach": false, "Tty": true})
  end

  def test(cid, user_id, problem_id, test_id, language) do
    time1 = :os.system_time(:millisecond)
    output = create(cid, Juice.build_command(user_id, problem_id, test_id, language))
          |> start()
    time2 = :os.system_time(:millisecond)
    res = %{output: output, time: time2 - time1}
    # TODO need to pull stderr, and throw a {:error, msg} on any errors
    case output do
      _ ->
        {:success, res}
    end
  end
end


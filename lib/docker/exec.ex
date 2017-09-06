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
    IO.puts exec
    exec["Id"]
  end

  def start(eid) do
    Docker.Rest.post("exec/#{eid}/start", %{
      "Detach": false, 
      "Tty": true
    })
  end
end


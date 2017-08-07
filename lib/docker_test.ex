defmodule DockerTest do
  def imagename, do: "nonis/baseimage"
  
  def run(command) do
    result = Dockerex.Client.post("containers/create", 
      %{"Image": imagename,
        "Tty": true,
        "HostConfig": %{"RestartPolicy": %{ "Name": "always"}}})
    cid = result["Id"]

    Dockerex.Client.post("containers/#{cid}/start")
    
    exec = Dockerex.Client.post("containers/#{cid}/exec", 
      %{"AttachStdin": true,
        "AttachStdout": true,
        "AttachStderr": true,
        "Cmd": command,
        "DetachKeys": "ctrl-p,ctrl-q",
        "Privileged": true,
        "Tty": true,
        "User": "123:456"})
    eid = exec["Id"]

    output = Dockerex.Client.post("exec/#{eid}/start", %{"Detach": false,"Tty": true})
    IO.inspect output

    Dockerex.Client.post("containers/#{cid}/kill")

  end
end

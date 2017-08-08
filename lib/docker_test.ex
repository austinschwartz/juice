defmodule DockerTest do
  require MyConstants
  alias MyConstants, as: Const
  defmodule Container do
    def create() do
      result = Dockerex.Client.post("containers/create", 
        %{"Image": Const.imagename,
          "Tty": true,
          "HostConfig": %{
            "RestartPolicy": %{ "Name": "always"},
            "Binds": [
              Const.testcases_src <> ":" <> Const.testcases_dst <> ":ro"
            ]
          }
        })
      result["Id"]
    end

    def start(cid) do
      Dockerex.Client.post("containers/#{cid}/start")
      cid
    end

    def kill(cid) do
      Dockerex.Client.post("containers/#{cid}/kill")
      cid
    end
  end

  defmodule Exec do
    def create(cid, command) do
      exec = Dockerex.Client.post("containers/#{cid}/exec", 
        %{"AttachStdin": true,
          "AttachStdout": true,
          "AttachStderr": true,
          "Cmd": command,
          "DetachKeys": "ctrl-p,ctrl-q",
          "Privileged": true,
          "Tty": true,
          "User": "123:456"})
      exec["Id"]
    end

    def start(eid) do
      Dockerex.Client.post("exec/#{eid}/start", %{"Detach": false,"Tty": true})
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

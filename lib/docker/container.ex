defmodule Docker.Client.Container do
  def create() do
    binds = [
      Juice.testcases_src <> ":" <> Juice.testcases_dst
    ]
    image = Juice.imagename
    create(image, binds)
  end

  def create(image, binds) do
    result = Docker.Rest.post("containers/create", 
      %{"Image": image,
        "Tty": true,
        "HostConfig": %{
          "RestartPolicy": %{ "Name": "always"},
          "Binds": binds
        }
      })
    result["Id"]
  end

  def start(cid) do
    Docker.Rest.post("containers/#{cid}/start", "")
    cid
  end

  def kill(cid) do
    Docker.Rest.delete("containers/#{cid}?force=true")
    cid
  end
end

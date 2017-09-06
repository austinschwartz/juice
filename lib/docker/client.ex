defmodule Docker.Client do
  def imagename, do: Application.get_env(:juice, :imagename)
  def testcases_src, do: Application.get_env(:juice, :testcases_src)
  def testcases_dst, do: Application.get_env(:juice, :testcases_dst)
end

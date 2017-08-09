defmodule MyConstants do
  use Constants
  define imagename, "nonis/baseimage"
  define testcases_src, "/home/nonis/testcases"
  define testcases_dst, "/testcases"
  define opt, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]
end

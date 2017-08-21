Juice
==========

![Picture of some delicious Orange Juice](orangejuice.jpg)

[![Build Status](https://api.travis-ci.org/austinschwartz/juice.svg)](https://travis-ci.org/austinschwartz/juice)

1. Add your docker host to the config/config.ex, including the ssl information if you want (see: Dockerex readme):
```
  host: "http://xxx:2376/"
```

2. Directories are hardcoded right now, but they're listed at the top of the juice.ex file. On the docker host, it looks like this:

```
[~/testcases] : tree                                                                         11:44:16
.
└── 00001
    ├── nonis
    │   ├── 1.txt
    │   ├── 2.txt
    │   ├── 3.txt
    │   ├── 4.txt
    │   ├── Main.class
    │   ├── Main.java
    │   └── Main$MyScanner.class
    ├── Solution.java
    └── tests
        ├── i1.txt
        ├── i2.txt
        ├── i3.txt
        ├── i4.txt
        ├── o1.txt
        ├── o2.txt
        ├── o3.txt
        ├── o4.txt

```

3. Success Example:
```elixir
iex(2)> Juice.test("nonis", "00001", "1", "Java")

%{diff: nil,
  given: %{language: "Java", problem_id: "00001", test_id: "10",
      user_id: "nonis"}, message: "success",
        result: %{output: "Lobster\r\n", time: 232}, status: :success}
```

Failure Example:
```elixir
iex(2)> Juice.test("nonis", "00001", "10", "Java")

%{diff: "1c1\r\n< Lobster\r\n---\r\n> no Lobster\r\n",
  given: %{language: "Java", problem_id: "00001", test_id: "10",
      user_id: "nonis"}, message: "output differed",
        result: %{output: "Lobster\r\n", time: 378}, status: :failure}
```

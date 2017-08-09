Juice
==========

![Picture of some delicious Orange Juice](orangejuice.jpg)

1. Add your docker host to the config/config.ex, including the ssl information if you want (see: Dockerex readme):
```
  host: "http://xxx:2376/"
```

2. Directories are hardcoded right now, but they're listed at he top of the juice.ex file. On the docker host, it looks like this:

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

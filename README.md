# Project 2

### Group Members

- **Kalpak Seal** - 8241-7219
- **Sagnik Ghosh** - 3363-6044

### Instruction to execute the project

After unzipping the file

```shell
cd proj2
mix run --no-halt proj2.exs node_count topology algorithm
```

Example:

```shell
cd proj2
mix run --no-halt proj2.exs 1000 honeycomb gossip
```

### Questions asked in Problem Statement

##### What is working?

We have implemented all the desired topologies and implemented both the algorithms.

##### What is the largest network you managed to deal with for each type of topology and algorithm?

| Topology        | Gossip | Push Sum |
| --------------- | ------ | -------- |
| line            | 500    | 2000     |
| full            | 8000   | 3000     |
| rand2D          | 3000   | 5000     |
| 3DTorus         | 8000   | 8000     |
| Honeycomb       | 4000   | 15000    |
| randomHoneycomb | 10000  | 20000    |
---
title: "Distributed Programs and MPI"
toc: true
type: docs
weight: 21
menu:
    parallel_programming:
        parent: Distributed-Memory Programming
        weight: 21
---

Programming in the distributed-memory model requires some low-level management of data distribution and communication.

## Partitioning

Partitioning refers to dividing computation and data into pieces or chunks. There are basically two ways to split up the workload.

**Domain decomposition**

Domain decomposion divides the data into chunks.  Typically these data are represent in some array-like form, though other data structures are possible.  The portion of the data known only to a particular process is often said to be _local_ to that process.  Data that is known to all processes is _global_.  The programmer must then determine how to associate computations with the local data for each process.

**Functional decomposition**

In functional or task decomposition, the tasks performed by the computation is divided among the processes.

### Partitioning Checklist

In distributed-memory programming, it is particularly important to maximize the computation to communication ratio, due to communication overhead.  The programmer should also minimize redundant computations and redundant data storage. As an example of avoiding redundant data, generally a program should not simply declare a large number of global arrays and then have each process determine which subset to use.  This usually wastes memory and may also make the program infeasible, since each process will consume a large amount of memory.  The programmer must determine how to distribute the data to each local array.

In addition, the quantity of work on each process should be roughly the same size (load balancing).  The number of tasks is generally an increasing function of problem size so tasks and/or their data should be divided equally among the processes.

## Communication

The programmer must determine the values to be passed among the tasks.  Only the necessary data should be communicated.  The type of communication may be _local_, in which the task needs values from a small number of other processes, or _global_,  where a significant number of processes contribute data to perform a computation

The goal is to balance communication operations among tasks, and to keep communications as local as possible.

**Agglomeration**

We prefer to group tasks into larger tasks.  Here the goals are to improve performance, maintain scalability of the program, and simplify programming.

Due to overhead, it is better to send fewer, larger messages than more, smaller messages.  In MPI programming, in particular, the goal is often to create one agglomerated task per processor.

**Mapping**

Mapping is the process of assigning tasks to processes or threads. For threading (SMP), the mapping done by operating system. In a distributed memory system, the user chooses how many processes, how many nodes, and how many cores per node.  These choices can affect performance.

Mapping has the often conflicting goals of maximizing processor utilization and minimizing interprocess communication.  Optimal mapping is probably unsolvable in general, so the programmer must use heuristics and approximations.  Frequently, determing the best mapping requires experimentation (scaling studies).

## MPI

MPI stands for  _M_ essage  _P_ assing  _I_ nterface.  It is a standard established by a committee of users and vendors.  

MPI is written in C and ships with bindings for Fortran.  Bindings have been written for many other languages, including Python and R. C\+\+ programmers should use the C functions.

MPI programs are run under the control of an executor or _process manager_.  The process manager starts the requested number of processes on a specified list of hosts, assigns an identifier to each process, then starts the processes.  Each copy has its own global variables\, stack\, heap\, and program counter.

Usually when MPI is run the number of processes is determined and fixed for the lifetime of the program.  The MPI3 standard can spawn new processes but in a resource managed environment such as a high-performance cluster, the total number must still be requested in advance.

MPI distributions ship with a process manager called  `mpiexec`  or  `mpirun`. In some environments, such as many using Slurm, we use the Slurm process manager  `srun`.

When run outside of a resource-managed system, we must specify the number of processes through a command-line option.  If more than one host is to be used, the name of a hostlist file must be provided, or only the local host will be utilized.  The options may vary depending on the distribution of MPI but will be similar to that below:
```
mpiexec –np 16 -hosts compute1,compute2  ./myprog
```

When running with srun under Slurm the executor does  _not_  require the `-np` flag; it computes the number of processes from the resource request.  It is also aware of the hosts assigned by the scheduler.
```
srun ./myprog
```
### Message Envelopes

A _communicator_ is an object that specifies a group of processes that will communicate with one another. The default communicator is
`MPI_COMM_WORLD`. It includes all processes.  The programmer can create new communicators, usually of subsets of the processes, but this is beyond our scope.

In MPI the process ID is called the **rank**.  Rank is relative to the communicator, and is numbered from zero.  Process 0 is often called the *root process*.

A message is uniquely identified by its
- Source rank
- Destination rank
- Communicator
- Tag

The "tag" can often be set to an arbitrary value such as zero.  It is needed only in cases where there may be multiple messages from the same source to the same destination in a short time interval, or a more complete envelope is desired for some reason.

### Message Buffers

MPI documentation refers to "send buffers" and "receive buffers." These refer to  _variables_ in the program whose contents are to be sent or received.  These variables must be set up by the programmer.  The send and receive buffers cannot be the same unless the special "receive buffer" `MPI_IN_PLACE` is specified.

When a buffer is specified, the MPI library will look at the starting point in memory (the pointer to the variable).  From other information in the command, it will compute the number of bytes to be sent or received.  It will then set up a separate location in memory; this is the actual buffer. Often the buffer is not the same size as the original data since it is just used for streaming within the network.  In any case, the application programmer need not be concerned about the details of the buffers and should just regard them as _variables_.  

For the send buffer, MPI will copy the sequence of bytes into the buffer and send them over the appropriate network interface to the receiver.  The receiver will acquire the stream of data into its receive buffer and copy them into the variable specified in the program. 

## Programming Languages

Many of the examples in this lecture are C or C\+\+ code, with some Fortran and Python examples as well.  All of the C functions work the same for Fortran, with a slightly different syntax.  They are mostly the same for Python but the most widely used set of Python bindings, `mpi4py`, was modeled on the deprecated C\+\+ bindings, as they are more "Pythonic."

Guides to the most-commonly used MPI routines for the three languages this course supports can be downloaded.

[C/C++](/courses/parallel_computing_introduction/MPI_Guide_C.pdf) 

[Fortran](/courses/parallel_computing_introduction/MPI_Guide_Fortran.pdf) 

[Python](/courses/parallel_computing_introduction/MPI_Guide_mpi4py.pdf)
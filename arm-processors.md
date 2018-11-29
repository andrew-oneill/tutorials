# What's the deal with ARM?

This article attempts to shed some light on what ARM is and why it is becoming so ubiquitious in today's technology devices.

Much of the inspiration and credit for this post is to be attributed to Professor Eric Roberts' site here: https://cs.stanford.edu/people/eroberts/courses/soco/projects/risc/risccisc/. Much of what has been said here can be found in his article.

## What is it?

ARM is a processor architecture that is an acronym for Advanced RISC Machines, the company who designs and licenses ARM.

- Arm is a Reduced Instruction Set Computing (RISC) architecture.
- There are other manufacturers that create RISC architectures but ARM is the mode widely used.

The Intel processors in our laptops are based on an architecture called x86, named because Intel, who created the architecture, ended the model numbers of the processors in 86 for a time (e.g. 80286, 80386, 80486).

- x86 is a Complex Instruction Set Computing (CISC) architecture.
- x86 is arguably the only chip these days which retains a CISC architecture.

That is all well and good, but its not much use know whether instruction sets are complex vs reduced without knowing what an instruction is.

## What are CPU instructions?

Instructions are logical commands built into the CPU that performs operations. They use a chains of transistors (switches) that respond to electrical signals. The following are just a couple of many types of logic gates that can be chained together to create instructions:

| GATE | IMAGE                                                        | OPERATION                           |
| ---- | ------------------------------------------------------------ | ----------------------------------- |
| AND  | ![AND Gate](https://github.com/andrew-oneill/tutorials/blob/master/resources/arm-processors/100px-AND_ANSI.svg.png) | Output true if both inputs are true |
| OR   | ![OR Gate](https://github.com/andrew-oneill/tutorials/blob/master/resources/arm-processors/100px-OR_ANSI.svg.png) | Output true if either input is true |

We tell CPUs to perform these instructions by writing assembly code. Because Assembly code is very verbose of convoluted for us to write (it is not much like English), we write code using higher level languages, such as Javascript, which web browsers compile into Assembly and then execute.

The primary goal of CISC architecture is to complete a task in as few lines of assembly as possible. This is achieved by building processor hardware that is capable of understanding and executing a series of operations together as a single instruction.

This video gives a great introduction to these logic gates and how they can be combined by computers to perform arthmetic such as addition [https://youtu.be/VBDoT8o4q00](https://youtu.be/VBDoT8o4q00)

## What then is the difference between RISC and CISC?

RISC does not necessarily have less instructions than CISC, as the "reduced" term may imply. What "reduced" refers to is that:

- RISC instructions themselves perform fewer operations per instruction

Alternatively, as the primary goal of CISC architecture is to complete a task in as few lines of assembly as possible:

- CISC instructions performs many operations per instruction

CISC does this by building more complex instructions, consisting of multiple operations, into the processor itself as opposed to RISC which keeps the hardware coded instructions simple, performing only a very small number of operations per instruction.

Let's take a a look at how this would work in practice.



## How do CPU's perform work?

![Processor Model](https://github.com/andrew-oneill/tutorials/blob/master/resources/arm-processors/memoryfig.gif)

### Initial Setup

Note: this is a simplified example, a real CPUs + memory have many orders of magnitude more registers and memory locations that this simplified example.

- The main memory is divided into a table of locations: row 1: column 1 to row 6: column 4. Similar to excel.
  - When you open an app/program, during the initial loading period it is loading all the information and operations it will need to perform into the main memory.
  - The program basically says "I'm going to need this, and this, and this and these, oh and this..." and it is all loaded into memory (Random Access Memory or RAM).
- The execution unit is responsible for carrying out all computations. 
  - In some CPU's this is called the Arithmetic and Logic Unit (ALU).
- The execution unit can only operate on data that has been loaded into one of the six registers (A, B, C, D, E, or F).

### Example - Compute the product of two numbers

#### CISC

For this particular task, a CISC processor would come prepared with a specific instruction (we'll call it **MULT**). When executed, this instruction performs four operations:

1. Loads the two numbers from memory into two separate registers
2. Multiplies the numbers in the execution unit
3. Stores the product of the numbers in the appropriate register
4. Copies the number from the register back to memory.

This can be completed with one instruction: `MULT 2:3, 5:2`

**MULT** is what is known as a "complex instruction." It performs multiple operations for the single instruction. It operates directly on the computer's memory locations and does not require the programmer to explicitly call any loading or storing functions to copy from and to memory.

#### RISC

RISC processors use only simple instructions that execute very few operations per instruction. The "MULT" command described above could be divided into three separate instructions:

- **LOAD** moves data from the memory bank to a register

- **PROD** finds the product of two operands located within the registers

- **STORE** moves data from a register to the memory banks.

To perform the same exact series of steps described in the CISC example, a programmer would need to write **four** instructions, resulting in four lines of assembly:

```
LOAD A, 2:3      # load the value in memory location 2:3 into CPU register A
LOAD B, 5:2      # load the value in memory location 5:2 into CPU register B
PROD A, B	     # perform the product operation on the values stores in registers A and B 
STORE 2:3, A     # store the result from register A back in memory location 2:3
```

## CISC & RISC Comparison

The RISC way may seem like a much less efficient way of completing the operation because:

- *More code* - There are more lines of code, therefore more RAM is needed to store the assembly code instructions.
- *More complex compilers* - The compiler must also perform more work to convert a high-level language (e.g. C, Rust, etc.) statement into code of this form.

However, the RISC strategy also brings some very important advantages:

- *Time requirements* - Because each instruction requires only one clock cycle to execute, the entire program will execute in approximately the same amount of time as the multi-cycle **MULT** command.
- *Space and transitior requirements* - These RISC "reduced instructions" require less transistors and hardware space than the complex instructions, leaving more room for general purpose registers.
- *Power requirements* - Less transistors per processor means less power is required to run the processor.
- *Concurrency* - Because all of the instructions execute in a uniform amount of time (i.e. one clock), pipelining is possible.
- *Lazy clearing of registers* - Separating the **LOAD** and **STORE** instructions reduces the amount of work that the computer must perform. After a CISC-style **MULT** command is executed, the processor automatically erases the registers the instruction used. If one of the numbers needs to be used for another computation, the processor must re-load the data from the memory location into a register. In RISC, the number will remain in the register until another value is loaded in its place.

| CISC                                                         | RISC                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Emphasis on hardware                                         | Emphasis on software                                         |
| Includes multi-clock complex instructions                    | Single-clock, reduced instruction only                       |
| Memory-to-memory: "LOAD" and "STORE"
incorporated into other instructions | Register to register: "LOAD" and "STORE"
are independent instructions |
| Small code sizes, high cycles per second                     | Low cycles per second, large code sizes                      |
| Transistors used for storing complex instructions            | Spends more transistors on memory registers                  |

## The Performance Equation

The following equation is commonly used for expressing a computer's performance ability:

![Processor performance](https://github.com/andrew-oneill/tutorials/blob/master/resources/arm-processors/performanceeq.gif)

The CISC approach attempts to minimize the number of instructions per program, sacrificing the number of cycles per instruction.

RISC does the opposite, reducing the cycles per instruction at the cost of the number of instructions per program.

## Why is ARM only appearing now and why is innovation accelerating?

- RISCs didn't have software support for a long time. As mentioned RISC requires more work to be performed by the compiler when compiling a program to convert high level languages to the simpler RISC instructions.
- As x86 was already established and as RISC was more risky (heh) as a new paradigm. As such there was a reasonably high barrier to entry.
- As smart phones began to emerge requiring more compact and lower power processor designs, alternatives other than x86 had to be explored.
- Modularized production line:
  - In x86, Intel designs the architecture, the processors and fabricates the chips.
  - In ARM, ARM designs the architectures, but then licences it to other technology companies (e.g. Apple, Amazon, Qualcomm, etc.) who design the processors, who then outsource the production to a fabrication company (e.g. TSMC).
    - All components of the production line are individual businesses who need to generate profits in their market segments and remain solvent. This means each part of the production line has an impetus to become as efficient and cost effective as possible.
- Because ARM only license the architecture and don't design the processors using the architecture, companies can license ARM and create their own CPUs for their products. This allows for rapid ARM-based processor innovation via increased competition.

## References

https://cs.stanford.edu/people/eroberts/courses/soco/projects/risc/risccisc/

https://en.wikipedia.org/wiki/Logic_gate

https://youtu.be/VBDoT8o4q00


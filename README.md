# vbfcc: A simple Brainfuck compiler written in V

![build](https://github.com/SheatNoisette/vbfcc/actions/workflows/build.yml/badge.svg)

This is a simple Brainfuck compiler and interpreted written in V from scratch.

**It is not optimized and it is not meant to be. It's just a simple compiler
made out of curiosity on my free time.**

A lot of things can be improved, but I'm not planning to do it. I'm just sharing
it in case someone wants to use it as a reference. A lot of things can be better
optimized and rewritten in a better way.

Supports:
- Code generation
  - C
- Basic optimizations
- Integrated interpreter

Missing:
- Tests
- JIT

## Building

You need to have V installed on your system. You can get it from
[here](https://vlang.io).

```bash
$ v . -o vbfcc
```

If you want a build a bit more optimized:
```bash
$ v -prod -skip-unused -cflags "-O2" -gc none . -o vbfcc
$ strip vbfcc
```

## Usage

For usage information, run the following command:
```bash
$ ./vbfcc help
```

Compile a Brainfuck file to optimized C (default):
```bash
$ ./vbfcc build -opt hello.bf hello.c
```

Run a Brainfuck file:
```bash
$ ./vbfcc run hello.bf
```

## License
The compiler is licensed under the GNU GPLv3.0 license. See the LICENSE file
for more details.

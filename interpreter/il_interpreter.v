module interpreter

import middle
import os

pub struct ILInterpreterOptions {
	memory_size    int  // The size of the memory
	print_direct   bool // If true, print the output of the program directly to stdout
	dynamic_memory bool // If true, the memory will be dynamically allocated
}

[heap]
pub struct ILInterpreterState {
pub mut:
	memory          []u8   // The memory of the program
	pointer         u64    // Memory pointer
	output          string // The output of the program
	program_counter u64    // The program counter
}

// Get the content of the program
[inline]
pub fn (i ILInterpreterState) output() string {
	return i.output
}

// Print the output of the program
[inline]
pub fn (i ILInterpreterState) print() {
	println("'" + i.output() + "'")
}

// Print the state of the program
[inline]
pub fn (i ILInterpreterState) print_state() {
	println('pointer: ${i.pointer}')
	println('program_counter: ${i.program_counter}')
	println('memory: ${i.memory}')
}

// Simple interpreter using the intermediate code generated
pub fn run(code []middle.BFILToken, options ILInterpreterOptions) ?ILInterpreterState {
	mut state := ILInterpreterState{
		pointer: 0
		output: ''
		program_counter: 0
	}

	if options.memory_size <= 0 {
		return error('Error: memory size must be greater than 0')
	}

	// If we use dynamic memory, we only allocate 1 byte of memory, we will
	// allocate more memory if needed
	state.memory = match options.dynamic_memory {
		true {
			[u8(0)]
		}
		false {
			[]u8{len: options.memory_size}
		}
	}

	for code[state.program_counter].type_token != middle.BFILTokenType.exit {
		match code[state.program_counter].type_token {
			.move_left {
				if state.pointer == 0 {
					return error('Pointer out of bounds')
				}
				state.pointer--
			}
			.move_right {
				if state.pointer >= u64(options.memory_size) {
					error('Error: pointer out of bounds')
				}
				if state.pointer == u64(state.memory.len) - 1 {
					state.memory << 0
				}
				state.pointer++
			}
			.add {
				state.memory[state.pointer]++
			}
			.sub {
				state.memory[state.pointer]--
			}
			.output {
				state.output += state.memory[state.pointer].ascii_str()
				if options.print_direct {
					print(state.memory[state.pointer].ascii_str())
				}
			}
			.input {
				input := os.get_line()[0].ascii_str()
				state.memory[state.pointer] = u8(input[0])
			}
			.jump_if_zero {
				if state.memory[state.pointer] == 0 {
					state.program_counter = u64(code[state.program_counter].value) + 1
				}
			}
			.jump_if_not_zero {
				if state.memory[state.pointer] != 0 {
					state.program_counter = u64(code[state.program_counter].value) - 1
				}
			}
			else {}
		}
		state.program_counter++
	}

	return state
}

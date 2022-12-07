module frontend

// Brainfuck AST

[heap]
pub struct BrainfuckASTNode {
pub mut:
	// Type of the node
	type_token LexerToken
	// Id of the node
	id int
	// Value of the node (inc/dec)
	value int
	// Start of the loop
	start_loop &BrainfuckASTNode
	// If it's a loop, end of the loop
	end_loop &BrainfuckASTNode
}

pub fn (bf &BrainfuckASTNode) get_type() LexerTokenType {
	return bf.type_token.token_type
}

pub fn (ast []&BrainfuckASTNode) print() {
	for node in ast {
		println('Node: ${node.type_token}')
	}
}

// First simple pass to create the AST
// - Annotations with IDs
// - Tags (token type) for each node
// Note: The loops are not resolved yet
fn parse_first_pass(tokens LexerTokenList) []&BrainfuckASTNode {
	mut ast := []&BrainfuckASTNode{}
	mut id := 0
	for i := 0; i < tokens.len(); i++ {
		current_token := tokens.get(i)

		// Create a new node
		mut current_node := &BrainfuckASTNode{
			id: id
			type_token: current_token
			value: 0
			start_loop: 0
			end_loop: 0
		}

		match current_token.token_type {
			.increment, .decrement {
				current_node.value = 1
			}
			.pointer_left, .pointer_right {
				current_node.value = 1
			}
			else {}
		}
		ast << current_node
		id++
	}
	return ast
}

// From the ast, resolve the loops
fn resolve_loops(bf []&BrainfuckASTNode) !map[int]int {
	// Contains the loop start '[' - jump_past / jump_back ']'
	mut loop_stack := []int{}

	// Contains the mapping between the start and end of the loop based on ids
	mut loop_map := map[int]int{}

	for node in bf {
		match node.get_type() {
			.jump_back, .jump_past {
				loop_stack << node.id
			}
			else {}
		}
	}

	// Check if the stack is divisible by 2
	if loop_stack.len % 2 != 0 {
		return error('Unbalanced loops')
	}

	// Find the middle of the stack
	mut last := loop_stack.len
	mut first := 0

	for last != first {
		// Get the first and last element
		loop_map[loop_stack[first]] = loop_stack[last - 1]
		loop_map[loop_stack[last - 1]] = loop_stack[first]
		last--
		first++
	}

	// Add to the map
	return loop_map
}

// Parse a Brainfuck program into an AST
pub fn parse(mut tokens LexerTokenList) ![]&BrainfuckASTNode {
	mut ast := parse_first_pass(tokens)
	loops_resolved := resolve_loops(ast) or { return error('Could not resolve loops: ${err}') }

	// Cache the nodes (id -> node)
	mut nodes := map[int]&BrainfuckASTNode{}
	for node in ast {
		nodes[node.id] = node
	}

	// Resolve the loops
	for mut node in ast {
		match node.get_type() {
			// ]
			.jump_back {
				node.start_loop = nodes[loops_resolved[node.id]]
			}
			// [
			.jump_past {
				node.end_loop = nodes[loops_resolved[node.id]]
			}
			else {}
		}
	}

	return ast
}

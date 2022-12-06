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
	// Is the node empty
	empty bool
}

pub fn (bf &BrainfuckASTNode) get_type() LexerTokenType {
	return bf.type_token.token_type
}

pub fn (ast []&BrainfuckASTNode) print() {
	for node in ast {
		println('Node: $node.type_token')
	}
}

// Parse a Brainfuck program into an AST
pub fn parse(mut tokens LexerTokenList) []&BrainfuckASTNode {
	mut ast := []&BrainfuckASTNode{}
	mut current_node := &BrainfuckASTNode{}
	mut loop_stack := []&BrainfuckASTNode{}
	mut loop_end := []&BrainfuckASTNode{}
	mut current_id := 0

	// For every token, get the end of the loop
	for token in tokens.tokens {
		if token.token_type == .jump_past {
			loop_end << current_node
		}
	}

	for tokens.len() > 0 {
		mut token := tokens.pop()
		current_node.id = current_id
		match token.token_type {
			.increment {
				current_node.type_token = token
				current_node.value = 1
			}
			.decrement {
				current_node.type_token = token
				current_node.value = 1
			}
			.pointer_left {
				current_node.type_token = token
				current_node.value = 1
			}
			.pointer_right {
				current_node.type_token = token
				current_node.value = 1
			}
			.output {
				current_node.type_token = token
				current_node.value = 0
			}
			.input {
				current_node.type_token = token
				current_node.value = 0
			}
			.jump_past {
				current_node.type_token = token
				current_node.value = 0
				loop_stack << current_node
			}
			.jump_back {
				current_node.type_token = token
				current_node.value = 0
				mut loop_start := loop_stack.pop()
				loop_start.end_loop = current_node
				current_node.start_loop = loop_start
			}
			else {}
		}
		ast << current_node
		current_node = &BrainfuckASTNode{}
		current_id++
	}

	// Return the root node
	return ast
}

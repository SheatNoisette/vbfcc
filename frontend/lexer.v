module frontend

// Token definitions
pub enum LexerTokenType {
	unknown
	increment // +
	decrement // -
	pointer_left // <
	pointer_right // >
	output // .
	input // ,
	jump_past // [
	jump_back // ]
	comment // Other characters
	line_return // \n
}

// A token is a single character in the source code
pub struct LexerToken {
	token_type LexerTokenType
	line       int // Line number
	column     int // Column number
}

// A list of tokens
[heap]
struct LexerTokenList {
mut:
	tokens []LexerToken
}

// Add a token to the list
fn (mut l LexerTokenList) add(token LexerTokenType, line int, column int) {
	l.tokens << LexerToken{
		token_type: token
		line: line
		column: column
	}
}

// Get an element from the list
fn (l LexerTokenList) get(index int) LexerToken {
	return l.tokens[index]
}

// Get the length of the list
// This is a synonym for LexerTokenList.tokens.len
fn (l LexerTokenList) len() int {
	return l.tokens.len
}

// Pop the first element of the list
fn (mut l LexerTokenList) pop() LexerToken {
	// Remove first element
	element := l.tokens[0]
	// Remove first element
	l.tokens = l.tokens[1..]
	return element
}

// Lex a string into a list of tokens
// input: The string to pass to the lexer
pub fn lex_string(input string) LexerTokenList {
	mut tokens := LexerTokenList{}
	mut current_line := 1
	mut current_column := 0

	for i := 0; i < input.len; i++ {
		current_column++
		match input[i] {
			`+` {
				tokens.add(LexerTokenType.increment, current_line, current_column)
			}
			`-` {
				tokens.add(LexerTokenType.decrement, current_line, current_column)
			}
			`<` {
				tokens.add(LexerTokenType.pointer_left, current_line, current_column)
			}
			`>` {
				tokens.add(LexerTokenType.pointer_right, current_line, current_column)
			}
			`.` {
				tokens.add(LexerTokenType.output, current_line, current_column)
			}
			`,` {
				tokens.add(LexerTokenType.input, current_line, current_column)
			}
			`[` {
				tokens.add(LexerTokenType.jump_past, current_line, current_column)
			}
			`]` {
				tokens.add(LexerTokenType.jump_back, current_line, current_column)
			}
			`\n` {
				tokens.add(LexerTokenType.line_return, current_line, current_column)
				current_line++
				current_column = 0
			}
			else {
				tokens.add(LexerTokenType.comment, current_line, current_column)
				current_column++
			}
		}
	}

	return tokens
}

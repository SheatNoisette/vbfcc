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

fn (mut l LexerTokenList) add(token LexerTokenType, line int, column int) {
	l.tokens << LexerToken{
		token_type: token
		line: line
		column: column
	}
}

fn (l LexerTokenList) get(index int) LexerToken {
	return l.tokens[index]
}

fn (l LexerTokenList) len() int {
	return l.tokens.len
}

fn (mut l LexerTokenList) pop() LexerToken {
	// Remove first element
	element := l.tokens[0]
	// Remove first element
	l.tokens = l.tokens[1..]
	return element
}

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
				current_line++
				current_column = 0
			}
			else {
				current_column++
			}
		}
	}

	return tokens
}

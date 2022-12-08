module middle

// Simplify add and sub instructions.
// add, add, add -> add 3
// sub, sub, sub -> sub 3
fn concat_add_sub(mut il []BFILToken) {
	// This isn't the most optimal way to do this, but it works.
	mut current_token_position := 0
	mut last_token_position := 0
	tokens := [BFILTokenType.add, BFILTokenType.sub, BFILTokenType.move_left,
		BFILTokenType.move_right]

	for token in tokens {
		current_token_position = 0
		last_token_position = 0
		// Loop through all the il tokens.
		for current_token_position < il.len {
			// Find a add il token.
			for current_token_position < il.len && il[current_token_position].type_token != token {
				current_token_position++
			}

			if current_token_position >= il.len {
				break
			}

			// Find the last add il token.
			last_token_position = current_token_position + 1
			for il[last_token_position].type_token == token {
				last_token_position++
			}

			// Remove the add il tokens.
			for i := 0; i < last_token_position - current_token_position; i++ {
				il.delete(current_token_position)
			}

			// Add the new add il token.
			il.insert(current_token_position, BFILToken{
				type_token: token
				value: last_token_position - current_token_position
			})

			current_token_position++
		}
	}
}

// Optimize the given intermediate representation.
pub fn optimize_il(mut il []BFILToken) {
	// Simplify add, sub, move_left and move right instructions.
	concat_add_sub(mut il)
}

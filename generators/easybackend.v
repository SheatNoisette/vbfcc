module generators

import middle
import json

/*
** Load JSON file and to generate code
** Sadly, you can't use the integrated V template engine
*/

const (
	vbfcc_string_to_il = {
		'move_right':       middle.BFILTokenType.move_right
		'move_left':        middle.BFILTokenType.move_left
		'add':              middle.BFILTokenType.add
		'sub':              middle.BFILTokenType.sub
		'exit':             middle.BFILTokenType.exit
		'input':            middle.BFILTokenType.input
		'output':           middle.BFILTokenType.output
		'jump_if_zero':     middle.BFILTokenType.jump_if_zero
		'jump_if_not_zero': middle.BFILTokenType.jump_if_not_zero
	}
	vbfcc_il_to_string = {
		middle.BFILTokenType.move_right:       'move_right'
		middle.BFILTokenType.move_left:        'move_left'
		middle.BFILTokenType.add:              'add'
		middle.BFILTokenType.sub:              'sub'
		middle.BFILTokenType.exit:             'exit'
		middle.BFILTokenType.input:            'input'
		middle.BFILTokenType.output:           'output'
		middle.BFILTokenType.jump_if_zero:     'jump_if_zero'
		middle.BFILTokenType.jump_if_not_zero: 'jump_if_not_zero'
	}
)

struct EasyBackend {}

// Json mapping
struct EasyBackendJson {
	name              []string          [required]
	version           string
	author            string            [required]
	license           string            [required]
	file_extension    string            [required]
	prelude           string            [required]
	postlude          string            [required]
	function_prelude  string            [required]
	function_postlude string            [required]
	tokens            map[string]string [required]
}

// Replace elements such as:
// - @AUTHOR
// - @VERSION
// - @LICENSE
fn replace_simple_tokens(input string, content EasyBackendJson) string {
	mut output := input
	output = output.replace('@AUTHOR', content.author)
	output = output.replace('@VERSION', content.version)
	output = output.replace('@LICENSE', content.license)
	return output
}

// Replace element token
fn replace_element_token(input string, token_value int, token_id int) string {
	mut output := input
	output = output.replace('@TOKENID', token_id.str())
	output = output.replace('@TOKENVALUE', token_value.str())
	return output
}

// From a token, get the string representation fron the json
fn get_token_from_json(content EasyBackendJson, token middle.BFILToken) string {
	// Get the line from the json
	json_str := content.tokens[generators.vbfcc_il_to_string[token.type_token]]
	// Replace the token value
	return replace_element_token(json_str, token.value, token.id)
}

fn generate_from_json(content EasyBackendJson, options CodeGenInterfaceOptions) string {
	mut output := ''

	// Generate prelude
	if options.generate_function {
		output += replace_simple_tokens(content.function_prelude, content)
	} else {
		output += replace_simple_tokens(content.prelude, content)
	}

	// Generate code
	// Il -> Json -> Replace variables -> Append to output
	for tok in options.il {
		output += get_token_from_json(content, tok)
	}

	// Generate postlude
	if options.generate_function {
		output += replace_simple_tokens(content.function_postlude, content)
	} else {
		output += replace_simple_tokens(content.postlude, content)
	}

	return output
}

fn (backend EasyBackend) generate_code(json_input string, options CodeGenInterfaceOptions) ? {
	// Deserialize json
	content := json.decode(EasyBackendJson, json_input) or { return error('Invalid json') }
	output := generate_from_json(content, options)
	write_code_to_single_file_or_stdout(output, options.output_file, options.print_stdout) or {
		return error('Failed to write code')
	}
}

fn (backend EasyBackend) generate_code_from_file(json_file string, options CodeGenInterfaceOptions) ? {
	// Read json file
	json_input := os.read_file(json_file) or { return error('Failed to read json file') }
	// Generate code
	backend.generate_code(json_input, options) or { return error('Failed to generate code') }
}

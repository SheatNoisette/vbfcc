module generators

import middle
import json
import os

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

// Json mapping
struct EasyBackendJson {
	name              []string          [required]
	version           string
	description       string            [required]
	author            string            [required]
	variables         string
	license           string            [required]
	indent_begin      int               [required]
	indent_type       string            [required]
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
fn replace_simple_tokens(input string, content EasyBackendJson, options CodeGenInterfaceOptions) string {
	mut output := input
	output = output.replace('@AUTHOR', content.author)
	output = output.replace('@VERSION', content.version)
	output = output.replace('@LICENSE', content.license)
	output = output.replace('@DESCRIPTION', content.description)
	output = output.replace('@VARIABLES', content.variables)
	output = output.replace('@FILENAME', options.output_file)
	output = output.replace('@EXTENSION', content.file_extension)
	output = output.replace('@MEMORYSIZE', options.memory_size.str())
	return output
}

// Replace element token
fn replace_element_token(input string, indent int, token middle.BFILToken, options EasyBackendJson) string {
	mut output := input
	output = output.replace('@TOKENID', token.id.str())
	output = output.replace('@TOKENVALUE', token.value.str())
	output = output.replace('@INDENTVAL', indent.str())
	output = output.replace('@INDENT', options.indent_type.repeat(indent))
	output = output.replace('@POSTINDENT', options.indent_type.repeat(match indent {
		0 { 0 }
		else { indent - 1 }
	}))
	return output
}

// From a token, get the string representation fron the json
fn get_token_from_json(indent int, content EasyBackendJson, token middle.BFILToken) string {
	// Get the line from the json
	json_str := content.tokens[generators.vbfcc_il_to_string[token.type_token]]
	// Replace the token value
	return replace_element_token(json_str, indent, token, content)
}

fn generate_from_json(content EasyBackendJson, options CodeGenInterfaceOptions) string {
	mut output := ''
	mut indent := content.indent_begin

	// Generate prelude
	if options.generate_function {
		output += replace_simple_tokens(content.function_prelude, content, options)
	} else {
		output += replace_simple_tokens(content.prelude, content, options)
	}

	// Generate code
	// Il -> Json -> Replace variables -> Append to output
	for tok in options.il {
		indent = match tok.type_token {
			.jump_if_zero { indent + 1 }
			.jump_if_not_zero { indent - 1 }
			else { indent }
		}
		output += get_token_from_json(indent, content, tok)
	}

	// Generate postlude
	if options.generate_function {
		output += replace_simple_tokens(content.function_postlude, content, options)
	} else {
		output += replace_simple_tokens(content.postlude, content, options)
	}

	return output
}

fn egen_generate_code(json_input string, options CodeGenInterfaceOptions) ? {
	// Deserialize json
	content := json.decode(EasyBackendJson, json_input) or { return error('Invalid json') }
	output := generate_from_json(content, options)
	write_code_to_single_file_or_stdout(output, options.output_file, options.print_stdout) or {
		return error('Failed to write code')
	}
}

fn egen_generate_code_from_file(json_file string, options CodeGenInterfaceOptions) ? {
	// Read json file
	json_input := os.read_file(json_file) or { return error('Failed to read json file') }
	// Generate code
	egen_generate_code(json_input, options) or { return error('Failed to generate code') }
}

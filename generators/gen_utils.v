module generators

import os

// Write code to a file
// If stdout is true, the code will be printed to stdout
fn write_code_to_single_file_or_stdout(code string, file string, stdout bool) ? {
	if stdout {
		println(code)
	} else {
		mut f := os.create(file) or { return error('Could not create file ${file}') }
		f.write_string(code) or { return error('Could not write to file ${file}') }
		f.close()
	}
}

// Indent a string
// indent_char is the character used to indent (usually a tab or a space)
// indent_nb is the number of indent_char to use
// input is the string to indent
fn indent_str(indent_char string, indent_nb int, input string) string {
	return indent_char.repeat(indent_nb) + input
}

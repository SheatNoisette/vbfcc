module generators

import middle
import frontend

pub struct CodeGenInterfaceOptions {
pub:
	output_file      string
	custom_arguments map[string]string
	il               []middle.BFILToken
	ast              []&frontend.BrainfuckASTNode
}

interface CodeGenInterface {
	generate_code(options CodeGenInterfaceOptions) ?
}

pub fn generator_call_backend(backend_name string, options CodeGenInterfaceOptions) ? {
	match backend_name {
		'c', 'cgen' {
			mut cgen := CGenBackend{}
			return cgen.generate_code(options)
		}
		else {
			return error('Unknown backend: ' + backend_name)
		}
	}
}

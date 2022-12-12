module generators

import middle
import frontend

// Base options for the code generator
pub struct CodeGenInterfaceOptions {
pub:
	output_file       string   // The output file
	custom_arguments  []string // Custom arguments for the backend
	optimize          bool     // Whether to optimize the code (if the backend supports it)
	print_stdout      bool     // Whether to print the output to stdout
	generate_function bool     // Whether to generate a function instead of a main
	memory_size       int      // The size of the memory
	il                []middle.BFILToken // The intermediate representation
	ast               []&frontend.BrainfuckASTNode // The AST (if needed)
}

// Interface for the EasyGen backend
struct EasyGenBackendDispatch {
mut:
	backend_json map[string]string // Contains the name -> json content of the backend
}

// Register every "EasyGen" backend
fn (mut dp EasyGenBackendDispatch) register_egen_backend(name string, json_str string) {
	dp.backend_json[name] = json_str
}

// Get a list of the available egen backends
fn (mut dp EasyGenBackendDispatch) str() string {
	mut res := 'Available EasyGen backends:\n'
	for key, _ in dp.backend_json {
		res += ' - ' + key + '\n'
	}
	return res
}

// Execute the EasyGen backend
fn (mut dp EasyGenBackendDispatch) generate_code(backend string, options CodeGenInterfaceOptions) ? {
	if backend !in dp.backend_json {
		eprintln('${dp}')
		return error('Backend ${backend} not found')
	}
	return egen_generate_code(dp.backend_json[backend], options)
}

// Dispatches the call to the correct backend
pub fn generator_call_backend(backend_name string, options CodeGenInterfaceOptions) ? {
	// Add the EasyGen backends
	mut dp := EasyGenBackendDispatch{}

	// Every EasyGen backend is registered here
	dp.register_egen_backend('cpp', $embed_file('generators/egen/cpp.json').to_string())
	dp.register_egen_backend('py', $embed_file('generators/egen/python.json').to_string())
	dp.register_egen_backend('js', $embed_file('generators/egen/nodejs.json').to_string())

	// Check backends
	match backend_name {
		// Hand written
		'c', 'cgen' {
			mut cgen := CGenBackend{}
			return cgen.generate_code(options)
		}
		'v', 'vlang' {
			mut vgen := VGenBackend{}
			return vgen.generate_code(options)
		}
		// Generated
		else {
			return dp.generate_code(backend_name, options)
		}
	}
}

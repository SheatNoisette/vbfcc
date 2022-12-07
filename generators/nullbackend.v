module generators

struct NullBackend {}

fn (backend NullBackend) generate_code(options CodeGenInterfaceOptions) ? {
	return error('Not implemented')
}

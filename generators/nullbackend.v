module generators

/*
** A empty backend that does nothing.
*/

struct NullBackend {}

fn (backend NullBackend) generate_code(options CodeGenInterfaceOptions) ? {
	return error('Not implemented')
}

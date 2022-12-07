module generators

import middle
import frontend

struct NullBackend {}

fn (backend NullBackend) generate_code(options CodeGenInterfaceOptions) ? {
	return error("Not implemented")
}

package cli

BuildFlags :: struct {
	release: bool `usage:"Build with optimizations."`,
	verbose: bool `usage:"Print detailed build logs.`,
	target:  string `usage:"Target architecture (e.g. x86_64, arm64, amd64, etc.)"`,
}


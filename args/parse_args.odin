package args

import "core:flags"
import "core:fmt"
import "core:os"

ExitCode :: enum {
	Success = 0,
	Error   = 1,
}

// CommandMap is a map of command names to their respective command structs
CommandMap :: map[string]Command

// CommandProc is a proc that takes a slice of argument strings and returns an ExitCode
CommandProc :: proc(args: []string) -> ExitCode

Command :: struct {
	name:        string,
	description: string,
	usage_hint:  string, // ex: "[options] <package_name>"
	run:         CommandProc,
}

// === FLAG DEFINITIONS ===

Build_Command_Flags :: struct {
	release: bool `usage:"Build with optimizations enabled."`,
	verbose: bool `usage:"Print detailed compilation logs."`,
}

Run_Command_Flags :: struct {
	debug: bool `usage:"Attach the debugger before running."`,
}

Add_Command_Flags :: struct {
	global: bool `usage:"Install the package globally."`,
}

// === PARSING & ROUTING ===


@(private = "file")
run_build :: proc(args: []string) -> ExitCode {
	options: Build_Command_Flags

	flags.parse_or_exit(&options, args, .Unix)

	fmt.printfln(
		"[Args] Parsed BUILD - Release: %v, Verbose: %v",
		options.release,
		options.verbose,
	)

	return .Success
}

@(private = "file")
run_run :: proc(args: []string) -> ExitCode {
	options: Run_Command_Flags
	flags.parse_or_exit(&options, args, .Unix)

	fmt.printfln("[Args] Parsed RUN - Debug: %v", options.debug)
	return .Success
}

@(private = "file")
run_add :: proc(args: []string) -> ExitCode {
	options: Add_Command_Flags
	flags.parse_or_exit(&options, args, .Unix)

	fmt.printfln("[Args] Parsed ADD - Global: %v", options.global)
	return .Success
}

Dispatch :: proc() -> ExitCode {
	commands := make(CommandMap)
	defer delete(commands)

	commands["build"] = Command {
		name        = "build",
		description = "Compile and execute the project.",
		run         = run_build,
	}

	commands["run"] = Command {
		name        = "run",
		description = "Compile and execute project",
		run         = run_run,
	}

	commands["add"] = Command {
		name        = "add",
		description = "Add a new dependency.",
		run         = run_add,
	}

	if len(os.args) < 2 {
		print_help(commands)
		return .Error
	}

	subcommand_name := os.args[1]
	cmd_args := os.args[2:]

	if cmd, ok := commands[subcommand_name]; ok {
		return cmd.run(cmd_args)
	}

	fmt.eprintfln("Error: Unknown command '%s'\n", subcommand_name)
	print_help(commands)
	return .Error
}

print_help :: proc(commands: CommandMap) {
	fmt.println("Usage: odm <command> [options]")
	fmt.println("\nCommands:")
	for name, cmd in commands {
		fmt.printfln("   %-10s %s", cmd.name, cmd.description)
	}
}

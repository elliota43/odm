package main

import "args"
import "core:fmt"
import "core:os"
import "toml"

main :: proc() {
	exit_code := args.Dispatch()

	os.exit(int(exit_code))
}

load_config_demo :: proc() {
	filepath := "ex_config.toml"
	fmt.eprintfln("Loading configuration from: %s\n---", filepath)

	doc, file_data, ok := toml.parse_file(filepath)
	if !ok {
		os.exit(1)
	}
	defer delete(file_data)

	for table_name, table in doc {
		if table_name == "" {
			fmt.println("[Root/Global Variables]")
		} else {
			fmt.printfln("[%s]", table_name)
		}

		for key, value in table {
			fmt.printfln(" %s = \"%s\"", key, value)
		}

		fmt.println()
	}
}


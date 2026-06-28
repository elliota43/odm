package toml

import "core:fmt"
import "core:io"
import "core:os"

parse_string :: proc(input: string) -> Toml_Document {
	l := Lexer {
		input = input,
		line  = 1,
	}

	advance(&l)

	tokens := make([dynamic]Token)
	defer delete(tokens)

	for {
		tok := next_token(&l)
		append(&tokens, tok)
		if tok.kind == .EOF do break
	}

	p := Parser {
		tokens = tokens,
		pos    = 0,
	}

	return parse_document(&p)
}

parse_file :: proc(filepath: string) -> (doc: Toml_Document, file_data: []u8, ok: bool) {
	data, err := os.read_entire_file_from_path(filepath, context.allocator)

	if err != io.Error.None {
		fmt.eprintfln("Error: could not read file '%s'", filepath)
		return nil, nil, false
	}


	file_content := string(data)
	return parse_string(file_content), data, true
}

package toml

import "core:fmt"

Parser :: struct {
	tokens: [dynamic]Token,
	pos:    int,
}

Toml_Table :: map[string]string

Toml_Document :: map[string]Toml_Table

peek :: proc(p: ^Parser) -> Token {
	if p.pos >= len(p.tokens) do return p.tokens[len(p.tokens) - 1]
	return p.tokens[p.pos]
}

expect :: proc(p: ^Parser, kind: Token_Kind) -> (Token, bool) {
	current := peek(p)
	if current.kind == kind {
		p.pos += 1
		return current, true
	}

	fmt.eprintf("Syntax Error on line %d: Expected %v, got %v\n", current.line, kind, current.kind)
	return current, false
}

parse_key_value :: proc(p: ^Parser) -> (key: string, value: string, ok: bool) {
	ident, ok1 := expect(p, .Identifier)
	if !ok1 do return "", "", false

	_, ok2 := expect(p, .Equals)
	if !ok2 do return "", "", false

	val, ok3 := expect(p, .String)
	if !ok3 do return "", "", false

	return ident.text, val.text, true
}

parse_table_header :: proc(p: ^Parser) -> (table_name: string, ok: bool) {
	_, ok1 := expect(p, .Left_Bracket)
	if !ok1 do return "", false

	ident, ok2 := expect(p, .Identifier)
	if !ok2 do return "", false

	_, ok3 := expect(p, .Right_Bracket)
	if !ok3 do return "", false

	return ident.text, true
}

parse_document :: proc(p: ^Parser) -> Toml_Document {
	doc := make(Toml_Document)

	current_table_name := ""
	doc[current_table_name] = make(Toml_Table)

	for p.pos < len(p.tokens) {
		tok := peek(p)

		#partial switch tok.kind {
		case .EOF:
			return doc

		case .Newline:
			p.pos += 1

		case .Left_Bracket:
			table_name, ok := parse_table_header(p)
			if ok {
				current_table_name = table_name

				if !(current_table_name in doc) {
					doc[current_table_name] = make(Toml_Table)
				}
			}

		case .Identifier:
			key, val, ok := parse_key_value(p)
			if ok {
				table := &doc[current_table_name]
				table[key] = val
			}

		case:
			fmt.eprintf("Syntax error on line %d: Unexpected token %v\n", tok.line, tok.kind)
			p.pos += 1
		}
	}

	return doc
}

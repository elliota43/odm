package toml

import "core:fmt"
import "core:unicode/utf8"
Lexer :: struct {
	input:    string,
	pos:      int,
	read_pos: int,
	line:     int,
	col:      int,
	cur_rune: rune,
}

advance :: proc(l: ^Lexer) {
	if l.pos >= len(l.input) {
		l.cur_rune = 0
		l.pos = l.read_pos
		return
	}

	r, width := utf8.decode_rune_in_string(l.input[l.read_pos:])
	l.cur_rune = r
	l.pos = l.read_pos
	l.read_pos += width
	l.col += 1
}

next_token :: proc(l: ^Lexer) -> Token {
	skip_whitespace(l)

	start_pos := l.pos
	tok := Token {
		line   = l.line,
		column = l.col,
	}

	switch l.cur_rune {
	case 0:
		tok.kind = .EOF
	case '=':
		tok.kind = .Equals
		advance(l)
	case '[':
		tok.kind = .Left_Bracket
		advance(l)
	case ']':
		tok.kind = .Right_Bracket
		advance(l)
	case '\n':
		tok.kind = .Newline
		l.line += 1
		l.col = 0
		advance(l)

	case '"':
		return lex_string(l)
	case 'a' ..= 'z', 'A' ..= 'Z', '_', '-':
		return lex_identifier(l)

	case:
		tok.kind = .Invalid
		advance(l)
	}

	tok.text = l.input[start_pos:l.pos]
	return tok
}

skip_whitespace :: proc(l: ^Lexer) {
	for l.cur_rune == ' ' || l.cur_rune == '\t' || l.cur_rune == '\r' do advance(l)
}

is_valid_ident_char :: proc(r: rune) -> bool {
	switch r {
	case 'a' ..= 'z', 'A' ..= 'Z', '0' ..= '9', '-', '_':
		return true
	case:
		return false
	}
}

lex_identifier :: proc(l: ^Lexer) -> Token {
	start_pos := l.pos
	start_col := l.col

	for is_valid_ident_char(l.cur_rune) do advance(l)

	return Token {
		kind = .Identifier,
		text = l.input[start_pos:l.pos],
		line = l.line,
		column = start_col,
	}
}

lex_string :: proc(l: ^Lexer) -> Token {
	start_col := l.col

	advance(l)

	string_start_pos := l.pos

	for l.cur_rune != '"' && l.cur_rune != '\n' && l.cur_rune != 0 {
		if l.cur_rune == '\\' do advance(l)
		advance(l)
	}

	string_end_pos := l.pos
	string_value := l.input[string_start_pos:string_end_pos]

	if l.cur_rune == '"' do advance(l)
	else do fmt.eprintf("Lexer error on line %d: Unterminated string\n", l.line)

	return Token{kind = .String, text = string_value, line = l.line, column = start_col}
}

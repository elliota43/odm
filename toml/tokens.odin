package toml

Token_Kind :: enum {
	Invalid,
	EOF,
	Identifier,
	String,
	Equals,
	Left_Bracket,
	Right_Bracket,
	Newline,
}

Token :: struct {
	kind:   Token_Kind,
	text:   string,
	line:   int,
	column: int,
}

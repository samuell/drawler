import std.net.curl, std.stdio, std.regex;

void main() {
	string s = cast(string) get("http://saml.rilspace.org");
	auto link_regex = regex(r"http(s)?://[A-Za-z\.\/]+","g");
	
	foreach(m; match(s, link_regex)) {
		writefln("Link: %s", m.hit);
	}
}

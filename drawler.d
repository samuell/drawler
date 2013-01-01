import std.net.curl, std.stdio, std.regex, std.algorithm, std.string;

void main() {
	string curLink = "http://saml.rilspace.org";
	string s = cast(string) get(curLink);
	
	// Create compiled RegEx for fast execution 
	enum link_regex = ctRegex!("href=\"([^\"]+)\"","g");
	
	string[] links;
	
	foreach(match; match(s, link_regex)) {
		string link = match.captures[1];
		if (link.endsWith("/")) {
			link = chop(link);
		}
		if (link.startsWith("/")) {
			link = curLink ~ link;
		}
		links ~= link;
		writefln("Adding link %s ...", link);
	}
	
	foreach(l; links) {
		writefln("Link: %s", l);
	}
}

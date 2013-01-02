import std.net.curl, std.stdio, std.regex, std.algorithm, std.string;
import arsd.mysql;

void main(string[] args) {
    if (args.length < 2) {
        writeln("Error: You must specify an URL, like so: ./drawler http://example.com");
    } else {
        string currentUrl = args[1]; // Get the URL to start with, from the command line 
        string htmlData = cast(string) get(currentUrl); // Read the webpage (cast from char[] to string)
        string[] urls = extractUrls(htmlData, currentUrl);
        string title = extractTitle(htmlData);
        writefln("Title: %s", title); // TODO: Remove debug code
        
//        foreach(l; urls) {
//            writefln("Found url: %s", l);
//        }
        
        MySqlConnection mySqlConn = new MySqlConnection;
        mySqlConn.addLinks(urls);
    }
}

string[] extractUrls(string htmlData, string currentUrl) {
    string[] urls;
    // Create compiled RegEx (for fast execution) 
    enum urlRegex = ctRegex!("href=\"([^\"]+)\"","g");

    foreach(match; match(htmlData, urlRegex)) {
        string url = match.captures[1];
        url = stripTrailingSlash(url);
        url = ensureAbsoluteUrl(url, currentUrl);
        urls ~= url; // Add url to the urls array
    }
    return urls; 
}

string extractTitle(string htmlData) {
    string title;
    enum titleRegex = ctRegex!(r"<title.*?>(.*?)</title>","g");
    auto match = match(htmlData, titleRegex);
    title = match.captures[1];
    return title; 
}

string stripTrailingSlash(string url) {
    if (url.endsWith("/")) {
        url = chop(url); 
    }
    return url;
}

string ensureAbsoluteUrl(string url, string currentUrl) {
    if (url.startsWith("/")) {
        url = currentUrl ~ url;
    }
    return url;
}    

class MySqlConnection {
    MySql mysql;

    this() {
        this.mysql = new MySql("localhost", "drawler", "drawler", "drawler");
    }

    string[] getLinks() {
        string[] links;
        // ? based placeholders do conversion and escaping for you
        foreach(line; this.mysql.query("SELECT siteid, linkid FROM links")) {
             // access columns by name
             writefln("%s: %s", line["siteid"], line["linkid"]);
        } 
        return links;
    }
    
    void addLinks(string[] links) {
        foreach(link; links) {
            this.mysql.query("INSERT INTO drawler.links ( url ) VALUES ( ? );", link);
        }
    }
    
}
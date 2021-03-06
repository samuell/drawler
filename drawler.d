import std.net.curl;
import std.stdio;
import std.regex;
import std.algorithm;
import std.string;
import std.array;
import std.datetime;
import arsd.mysql;

void main(string[] args) {
    if (args.length < 2) {
        writeln("Error: You must specify an URL, like so: ./drawler http://example.com");
    } else {
        // Get the URL to start with, from the command line
        string currentUrl = args[1]; 
        // Read the webpage (cast from char[] to string)
        string htmlData = cast(string) get(currentUrl); 

        string[] urls;
        urls ~= currentUrl;
        writeln("URLS: ", urls, ", Current URL: ", currentUrl);
		urls ~= extractUrls(htmlData, currentUrl);

        // DEBUG CODE
//        foreach (url; urls) {
//            writeln(url);
//        }

        string title = extractTitle(htmlData);
        string fulltext = extractFulltext(htmlData);

        writefln("Title: %s", title); // TODO: Remove debug code
        //writefln("Fulltext: \n%s", fulltext); // TODO: Remove debug code

        MySqlConnection mySqlConn = new MySqlConnection;
        mySqlConn.addLinks(urls);
        mySqlConn.updateUrlWithFulltext(currentUrl, fulltext);
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
    enum titleRegex = ctRegex!(r"<title.*?>(.*?)</title>","g");
    auto match = match(htmlData, titleRegex );
    string title = match.captures[1];
    return title;
}

string extractFulltext(string htmlData) {
    string fullText;
    string bodyHtml;

    // Remove newline characters
    htmlData = join(htmlData.splitLines(), " ");

    enum bodyRegex = ctRegex!(r"<body.*?>(.*?)</body>","g");
    auto match = match(htmlData, bodyRegex);
    bodyHtml = match.captures[1];

    // Remove all HTML tags
    enum htmlTagRegex = ctRegex!(r"<[^\>]*?>","g");
    fullText = bodyHtml.replace(htmlTagRegex, "");

    // Remove excess whitespace / tabs
    enum excessSpaceRegex = ctRegex!(r"[\s\t]+","g");
    fullText = fullText.replace(excessSpaceRegex," ");

    // Remove non-word characters
    enum unallowedCharsRegex = ctRegex!(r"[^A-Za-z0-9\-\.\,\sÅÄÖåäö]","g");
    fullText = fullText.replace(unallowedCharsRegex,"");

    return fullText;
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

string currentDate() {
    string isotime = Clock.currTime.toISOString();
    string y = isotime[0..4];
    string m = isotime[4..6];
    string d = isotime[6..8];
    string currentDate = [y, m, d].join("-");
    // writeln("Current date: ", currentDate);
    return currentDate;
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
            if (this.mysql.query("SELECT url from links WHERE url LIKE ?;", link).length > 0) {
                // writefln("Found link: %s, so skipping it...", link);
            } else {
                writefln("Did NOT find link: %s, so adding it ...", link);
                this.mysql.query("INSERT INTO drawler.links ( url ) VALUES ( ? );", link);
            }

        }
    }

    void updateUrlWithFulltext(string url, string fulltext) {
        this.mysql.query("UPDATE links SET fulltxt='" ~ fulltext ~ "',indexdate='"~ currentDate() ~"' WHERE url='" ~ url ~ "';");
    }
}

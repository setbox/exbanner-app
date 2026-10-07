import csv
import html
import os
import re
import sys

scripts = os.path.dirname(os.path.abspath(__file__))
app = os.path.dirname(scripts)
site = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else "~/workspace/setbox/sites/setbox.github.io/oss/exbanner")

rows = sorted(csv.DictReader(open(os.path.join(scripts, "font_audit.csv"))), key=lambda r: r["atom"])

REMOVAL = (
    "ExBanner bundles fonts collected from the FIGlet community over the last decades. "
    "Many of them were published without a license, and some authors could not be reached. "
    "Each font is credited below as stated in its file. If you are the author of a font, or hold "
    "its rights, and want it removed or credited differently, write to contato@setbox.com.br and "
    "we will remove or update it in the next release."
)


def atom(name):
    return ":" + name if re.match(r"^[a-z_][a-z0-9_]*$", name) else ':"' + name + '"'


def terms(row):
    quote = row["license_quote"]
    notes = row["notes"].lower()
    if row["class"] == "FREE_CERTAIN":
        if "FIGlet 2.2.5" in quote:
            return "BSD-3-Clause (FIGlet 2.2.5 distribution)"
        if "WTFPL" in quote or "What The Fuck" in quote:
            return "WTFPL"
        return "MIT"
    if row["class"] == "RESTRICTED":
        return "Author's terms: commercial use requires contacting the author"
    if "modify" in notes:
        return "No license stated; the file allows modification with credit"
    if "copyright notice only" in notes:
        return "Copyright notice, no license stated"
    return "No license stated"


def author(row):
    value = row["author"].strip()
    return "Unknown" if value.lower() in ("", "unknown") else value


def source(row):
    url = row["source_url"]
    if "cmatsuoka/figlet" in url:
        label = "FIGlet 2.2.5"
    elif "xero/figlet-fonts" in url:
        label = "xero/figlet-fonts"
    else:
        label = "patorjk/figlet.js"
    return label, url


def md_cell(text):
    return text.replace("|", "\\|")


lines = [
    "# Font credits",
    "",
    f"ExBanner bundles {len(rows)} FIGlet and TOIlet fonts. This page credits each one to its author, with the terms stated in the font file and where the file came from.",
    "",
    "## Removal on request",
    "",
    REMOVAL,
    "",
    "## Fonts",
    "",
    "| Font | Author | Terms | Source |",
    "|---|---|---|---|",
]
for row in rows:
    label, url = source(row)
    lines.append(f"| `{atom(row['atom'])}` | {md_cell(author(row))} | {md_cell(terms(row))} | [{label}]({url}) |")
lines.append("")
open(os.path.join(app, "CREDITS.md"), "w").write("\n".join(lines))

index = open(os.path.join(site, "index.html")).read()
head, rest = index.split('<main id="top">', 1)
_, tail = rest.split("</main>", 1)
head = head.replace("<title>ExBanner - ASCII art banners for Elixir</title>", "<title>Font credits - ExBanner</title>")
head = re.sub(r'href="#(startup|render|fonts)"', r'href="index.html#\1"', head)
head = head.replace('href="#top"', 'href="index.html"')
tail = tail.replace('<script src="assets/scripts/fonts.js"></script>\n  ', "")

removal_html = html.escape(REMOVAL).replace(
    "contato@setbox.com.br", '<a href="mailto:contato@setbox.com.br">contato@setbox.com.br</a>'
)

body = [
    '<main id="top">',
    '    <section class="section container credits">',
    "      <h1>Font credits</h1>",
    f"      <p>ExBanner bundles {len(rows)} FIGlet and TOIlet fonts. Each one is credited to its author, with the terms stated in the font file.</p>",
    "      <h2>Removal on request</h2>",
    f"      <p>{removal_html}</p>",
    "      <h2>Fonts</h2>",
    '      <div class="table">',
    "        <table>",
    "          <thead><tr><th>Font</th><th>Author</th><th>Terms</th></tr></thead>",
    "          <tbody>",
]
for row in rows:
    body.append(
        f"            <tr><td><code>{html.escape(atom(row['atom']))}</code></td><td>{html.escape(author(row))}</td>"
        f"<td>{html.escape(terms(row))}</td></tr>"
    )
body += ["          </tbody>", "        </table>", "      </div>", "    </section>", "  </main>"]
open(os.path.join(site, "credits.html"), "w").write(head + "\n".join(body) + tail)

print(f"{len(rows)} fonts credited")

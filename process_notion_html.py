import os
import sys
import re
import chardet
import ftfy
from bs4 import BeautifulSoup

# Regex patterns
uuid_pattern = re.compile(r'[a-fA-F0-9]{32}')
percent_encoded_except_space = re.compile(r'%(?!20)[0-9a-fA-F]{2}')
unicode_escape_pattern = re.compile(r'\\u([0-9a-fA-F]{4})')

def detect_encoding(file_path):
    """Detect the encoding of a file using chardet."""
    with open(file_path, 'rb') as f:
        result = chardet.detect(f.read())
    return result['encoding'] or 'utf-8'

def replace_unicode_escapes(text):
    """Replace Unicode escape sequences with actual characters."""
    def replace(match):
        return chr(int(match.group(1), 16))
    return unicode_escape_pattern.sub(replace, text)

def clean_link(link):
    """Remove UUIDs and unwanted percent encodings from links."""
    link = uuid_pattern.sub('', link)
    link = percent_encoded_except_space.sub('', link)
    link = re.sub(r'/+', '/', link)
    return link

FONT_STYLE = '''
<link href="https://fonts.googleapis.com/css2?family=Noto+Color+Emoji&display=swap" rel="stylesheet">
<style>
body {
  font-family: "Noto Color Emoji", "Segoe UI Emoji", "Apple Color Emoji", "Noto Sans", Arial, sans-serif;
}
</style>
'''

def inject_font_style_and_charset(soup):
    """Inject charset meta tag and font style for emoji support."""
    if soup.head:
        has_charset = any(
            tag.name == "meta" and tag.get("charset", "").lower() == "utf-8"
            for tag in soup.head.find_all("meta")
        )
        if not has_charset:
            meta_tag = soup.new_tag("meta", charset="utf-8")
            soup.head.insert(0, meta_tag)
        if not soup.head.find(string=lambda s: s and "Noto Color Emoji" in s):
            soup.head.append(BeautifulSoup(FONT_STYLE, "html.parser"))

def process_html_file(file_path):
    """Process an HTML file to fix encoding, links, and ensure UTF-8 output."""
    encoding = detect_encoding(file_path)
    
    try:
        with open(file_path, 'r', encoding=encoding, errors='replace') as f:
            content = f.read()
    except Exception as e:
        print(f"[!] Error reading {file_path} with encoding {encoding}: {e}")
        return

    # Fix mojibake and encoding issues
    content = ftfy.fix_text(content)
    content = replace_unicode_escapes(content)

    # Parse and modify HTML
    soup = BeautifulSoup(content, 'html.parser')
    modified = False
    for tag in soup.find_all(['a', 'img', 'script', 'link']):
        for attr in ['href', 'src']:
            if tag.has_attr(attr):
                original = tag[attr]
                cleaned = clean_link(original)
                if cleaned != original:
                    tag[attr] = cleaned
                    modified = True

    # Ensure proper charset and font support
    inject_font_style_and_charset(soup)
    modified = True

    # Write back in UTF-8
    if modified or encoding.lower() != 'utf-8':
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(str(soup))
            print(f"[✓] Processed: {file_path} (original encoding: {encoding})")
        except Exception as e:
            print(f"[!] Error writing {file_path}: {e}")
    else:
        print(f"[i] No changes needed: {file_path}")

def main(root_dir):
    """Process all HTML files in the directory."""
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith('.html'):
                process_html_file(os.path.join(root, file))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python process_notion_html.py <folder_path>")
        sys.exit(1)
    main(sys.argv[1])
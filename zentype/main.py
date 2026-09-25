
"""
ZenType — a minimal typing app: paste your text and type.
Requires: pip install pywebview
"""

import webview
from pathlib import Path


def main():
    here = Path(__file__).parent
    html = (here / 'index.html').read_text(encoding='utf-8')
    # The window is fed an HTML string, so relative links don't resolve —
    # inline the shared stylesheet in place of its <link>.
    theme = (here.parent / 'shared' / 'theme.css').read_text(encoding='utf-8')
    html = html.replace('<link rel="stylesheet" href="../shared/theme.css">',
                        f'<style>\n{theme}</style>')

    webview.create_window(
        'ZenType',
        html=html,
        width=1280,
        height=800,
        min_size=(900, 600),
        background_color='#0d0d0d',
    )
    webview.start()


if __name__ == '__main__':
    main()

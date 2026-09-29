# RokuCalibreScreensaver

Display book covers from your Calibre libraries as a Roku screensaver.

Supported sources:
- USB drive with a top-level Calibre directory.
- Calibre Content Server.
- RokuCoverServer, the Python server in RokuCoverServer/server.py.

Many thanks to @kovidgoyal for creating Calibre.

## RokuCoverServer setup

1. Set ROOT in RokuCoverServer/server.py to the directory containing your Calibre library folders, then run it with Python 3. The default port is 8765.
2. Ensure the Roku can reach the server on your network.
3. In screensaver settings, select **Calibre Library Source → RokuCoverServer** and enter the base address, for example http://192.168.1.5:8765 (without /catalog.json). If you omit the scheme, http:// is added automatically.
4. Select **Ok**. The address and source are saved after the catalog returns at least one usable cover URL. RokuCoverServer has its own saved address, separate from Calibre Content Server.

The screensaver fetches /catalog.json once per launch and includes books from every library:

```json
{
  "libraries": [
    {
      "name": "Main",
      "books": [
        {"cover": "/files/Main/Author/Book/cover.jpg"}
      ]
    }
  ]
}
```

Root-relative cover paths are prefixed with the server address, preserving URL encoding. Absolute HTTP(S) cover URLs are also supported. Invalid entries are skipped and duplicate URLs are removed. Catalog requests time out after 10 seconds; unavailable, malformed, or empty catalogs use the bundled sample covers.

USB and Calibre Content Server remain available. All sources use the existing random cover selection, sizing, and scrolling. The existing display loop requires enough distinct, loadable covers to fill the screen; small catalogs and failed image downloads retain its existing limitations.

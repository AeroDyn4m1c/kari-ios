# kari-ios

Stream anime on your **iPhone / iPad** from the terminal and watch it in **VLC**, no Mac and no downloading needed.

It's a POSIX-shell port of the anime part of [kari](https://github.com/dhairya3391/kari), made to run in [iSH](https://ish.app) the same way [ani-cli](https://github.com/pystardust/ani-cli) used to.

```
$ kari frieren
Select anime: Frieren: Beyond Journey's End  (TV, 2023) [28 eps]
Episode (1-28): Episode 1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~  Tap here to open in VLC  ~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

## What you need

- **iSH Shell** (free, App Store)
- **VLC for Mobile** (free, App Store)

## Install

Open iSH and paste:

```sh
apk add curl
curl -sL https://raw.githubusercontent.com/AeroDyn4m1c/kari-ios/main/install.sh | sh
```

This installs the dependencies (`curl jq openssl fzf busybox-extras`) and puts `kari` in `/usr/local/bin`.

<details>
<summary>Manual install</summary>

```sh
apk add curl jq openssl fzf busybox-extras
curl -sL https://raw.githubusercontent.com/AeroDyn4m1c/kari-ios/main/kari -o /usr/local/bin/kari
chmod +x /usr/local/bin/kari
```
</details>

## Use

```sh
kari                 # asks what to search for
kari frieren         # search directly
kari -d one piece    # English dub
kari -e 5 frieren    # start at episode 5
kari -c              # continue watching (history)
kari -U              # update kari
kari -h              # all options
```

1. Pick the anime and the episode. Type to filter, then tap the item or press Enter.
2. Wait for **"Ready: first segment ..."**. kari checks that the video really comes through before it shows the link.
3. **Tap the green "Tap here to open in VLC" box.** VLC opens and starts playing, with English subtitles in sub mode.
4. When you're done, switch back to iSH and press **Enter**, then choose **next**, **replay**, **previous**, **select**, **switch to dub/sub**, **quality**, **search** or **quit**.

### First run: allow location access

The first time you play something, iOS asks whether **iSH** may use your location. Choose **Allow While Using App** (or **Always**).

kari doesn't use your location. Reading it is the standard trick that keeps iSH running in the background, and iSH needs to keep running while you watch (see below). If you say no, playback stops after a few seconds once VLC is in front.

## How it works

kari follows the same anime pipeline as the original kari's AniCine provider:

1. Search **AniList** for the title, which gives the episode count and MAL id.
2. Open the **Megaplay** embed for `MAL id / episode / sub|dub`.
3. Ask Megaplay for the sources and decrypt the AES token with `openssl`, which yields the HLS playlist.
4. Sign the CDN URL (HMAC-SHA256), as kari does.

The stream's CDN refuses any request without a `Referer` header, and VLC for iOS can't send one. On iSH, kari therefore starts a tiny proxy on `127.0.0.1:8642` (busybox `httpd` + a CGI script), and VLC plays `http://127.0.0.1:8642/...`.

A background job downloads the next ~80 seconds of video ahead of VLC, with the right headers and one connection per batch, because every new connection is slow inside iSH. Segments VLC has already played get deleted, so storage use stays small. All of this is why iSH has to stay alive in the background while VLC plays.

On a normal Linux/macOS machine kari skips the proxy and starts `mpv` or `vlc` directly with the headers.

## Settings

Set these as environment variables, e.g. in `~/.profile`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `KARI_MODE` | `sub` | `sub` or `dub` |
| `KARI_QUALITY` | `best` | `best`, `worst`, `1080`, `720`, `480`, `360` |
| `KARI_SUB_LANG` | `English` | subtitle language (`Spanish`, `French`, ...) or `none` |
| `KARI_PORT` | `8642` | local proxy port |
| `KARI_PLAYER` | auto | `iSH`, `mpv`, `vlc`, or `link` (just print the stream URL) |
| `KARI_NO_FZF` | | set to use a numbered menu instead of fzf |
| `KARI_NO_KEEPALIVE` | | set to skip the location background trick |
| `KARI_AHEAD` | `8` | how many segments (~10 s each) to buffer ahead of VLC |
| `KARI_DEBUG` | | set to show how long each step takes |

History is stored in `~/.local/state/kari/history`.

## Troubleshooting

- **VLC opens but nothing plays / stops after a few seconds.** iSH was suspended. Allow location access for iSH (Settings → iSH → Location → **Always**), and don't force-close iSH while watching. To see what the proxy did, run `cat ~/.cache/kari/proxy.log`: every line is one piece of video VLC asked for.
- **"Can't connect to the video server"**: your Wi-Fi or internet provider blocks the address the video CDN uses. kari can't fix that. Try mobile data or another network.
- **Slow to start.** Run `KARI_DEBUG=1 kari frieren` to see which step takes long. Lower quality (`kari -q 720 ...`) also buffers faster.
- **"Episode N (dub) is not available"**: that episode has no dub yet. Switch to sub.
- **"Local proxy failed to start"**: another program is using the port. Run `KARI_PORT=8700 kari`.
- **Nothing tappable appears**: update iSH. Older versions don't support terminal links.
- **Search or playback suddenly stops working**: the upstream site probably changed. Run `kari -U` to get the latest fixes.

## Credits

- [kari](https://github.com/dhairya3391/kari) by Dhairya (MIT), for the provider logic and Megaplay keys this is ported from.
- [ani-cli](https://github.com/pystardust/ani-cli), for the iSH and VLC approach.

This tool doesn't host any content; it only links to streams that are already public.

## License

MIT. See [LICENSE](LICENSE).

# archive-enter.yazi

Enter directories, open files, and transparently extract archives.

Pressing `l` on a supported archive extracts it into a sibling directory named after the archive with its suffix removed and a timestamp appended, then navigates into that directory.

```
data.tar.gz  ->  data_20261109_122530/
photos.zip   ->  photos_20261109_122530/
backup.rar   ->  backup_20261109_122530/
```

## Supported formats

| Format | Tool |
| --- | --- |
| `.zip`, `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.tar.zst`, `.tgz`, `.tbz2`, `.txz`, `.tzst` | `bsdtar` |
| `.rar` | `unrar` |
| `.7z` | `7z` |

## Keymap

```toml
[[mgr.prepend_keymap]]
on   = "l"
run  = "plugin archive-enter"
desc = "Enter directories and archives, or open files"
```

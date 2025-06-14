#!/usr/bin/env python3

import i3ipc
from threading import Timer

def find_parent(i3, window_id):
    """
        Find the parent of a given window id
    """
    def finder(con, parent):
        if con.id == window_id:
            return parent

        for node in con.nodes:
            res = finder(node, con)
            if res:
                return res

        return None

    return finder(i3.get_tree(), None)

def set_layout(i3, e):
    """
        Set the layout/split for the currently
        focused window to either vertical or
        horizontal, depending on its width/height
    """
    win = i3.get_tree().find_focused()
    if not win:
        return

    parent = find_parent(i3, win.id)

    if (parent and parent.layout not in ['tabbed', 'stacked']):
        if win.rect.height > win.rect.width:
            if parent.orientation == 'horizontal':
                i3.command('split v')
        else:
            if parent.orientation == 'vertical':
                i3.command('split h')

def main():
    i3 = i3ipc.Connection()
    i3.on('window::focus', set_layout)
    i3.main()

if __name__ == "__main__":
    main()

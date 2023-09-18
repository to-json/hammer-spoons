# hammer-spoons

## What's this?

Some hammerspoon spoons I consider 'done' enough that they could provide
value to others. Currently, by 'some' I mean 'one', but, that may someday
not be true.

### What spoons?

appWarp - run or raise bindings for osx applications.

Here's (most of) my config:

```
hs.loadSpoon("appWarp")
local appWarp_keys = {["appWarp"]={{"control"}, "\\"},
                      ["Alacritty"]={nil, "t"},
                      ["Slack"]={nil, "s"},
                      ["zoom.us"]={nil, "z"},
                      ["Firefox"]={nil, "w"},
                      ["Logseq"]={nil, "n"},
}
spoon.appWarp:bindModalHotKeys(appWarp_keys)
```

With this, I can hit `ctrl-\` followed by `t` to go to my terminal, or
followed by `w` to go to my browser, regardless of what I am currently
doing. I do not need to think about where that application is, or if 
it is currently minimized. I do not have to touch the mouse. Selecting an
application also dismisses the modal interface started by the `appWarp`
binding; think of it like the `leader` key in Vim if you use that.

As I write this, I'm realizing that displaying an app list would be useful.
Another day, maybe. (Update 9/18/23: this sorta works now, but, it sucks; 
still futzing with it)


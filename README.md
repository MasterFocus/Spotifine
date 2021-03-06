# !!! WARNING !!!
**!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**  
Many people are **unhappy** with the **latest version of Spotify (1.0.1.1060)**.  
Among many other bad/questionable things, **it also breaks my code**.  
But I can assure my code works with the previous version (**0.9.15.17.x**).  
So, here's a related link if you wish to **downgrade** and/or find more about it:  
https://www.reddit.com/r/spotify/comments/2y6a68/spotify_update_1011060gc75ebdfd_mega_discussion/cp6z9ba  
**!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**

# Spotifine
* This program is currently usable, but also a work-in-progress (probably nothing bad will happen, but use it at your own risk)
* Speaking about liability... this program is licensed under **GNU AGPL v3** (check the *LICENSE* file for more information - it's a quick read, I promise!)
* Use AHK **1.0.x** to run _Spotifine.ahk_, _**NOT**_ AHK **1.1.x** (see "_**Known Issues**_")
* This program uses _nircmd.exe_ and _Notify.ahk_, which were not created by me (see "_**Resources**_")

# Description
After many requests, I'm releasing this program. \o/ :)  
**Spotifine** automatically mutes **Spotify** if it tries to play any artists or songs that are blacklisted.  
By using _nircmd.exe_, **Spotifine** ensures that only **Spotify** is muted, not the whole system.  
(I don't even know what version of _nircmd.exe_ I'm using, so I also included a whole x64 zip file)

# How To
* Put all files in the same folder and run _Spotifine.ahk_ using the "old" AHK (1.0.48.05)
* Configure the program if you wish (configurable stuff is before the 60th line - you should be able to figure things out)
* If you want to block something as soon as it starts playing, just click the notification baloon to see your options (note: otherwise, you can't dismiss the baloon)

# Known Issues
* **Spotifine** works with the "old" AHK, not the latest version (this is probably a problem in _Notyfy.ahk_, which I may try to fix in the future)
* Some artists with '&' are not displayed correctly by the notification baloon (example: artist "_Cowboys & Aliens_")
* **Spotifine** doesn't necessarily unmute **Spotify** on exit (this should be an easy fix)
> Note: if you get stuck with a muted **Spotify**,  
> simply open **Spotifine** and then close **Spotifine**  

* There's no way to actively dismiss the notification baloon unless you wanna block the current artist/song (I'll try to add a right-click option or something, but it depends on how _Notify.ahk_ works)

# Resources
**Notify**, by **gwarble**: &nbsp; http://gwarble.com/ahk/Notify/  
**NirCmd**: &nbsp; http://www.nirsoft.net/utils/nircmd.html  
**AutoHotkey**: &nbsp; http://ahkscript.org/ &nbsp; and &nbsp; http://www.autohotkey.com/  

&nbsp;  
-- Antonio &nbsp; [ &nbsp; https://masterfocus.github.io/ &nbsp; ]
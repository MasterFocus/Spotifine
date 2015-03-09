/*
    Spotifine.ahk
    Copyright (C) 2014,2015 Antonio França

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#NoEnv
#KeyHistory 0
ListLines, Off
SetBatchLines, -1
; I like having Spotifine in high priority...
; You may comment the following line to avoid that
Process, Priority,, High
DetectHiddenWindows, On
#Persistent
; Includes "Notify", by gwarble
; Reference: http://gwarble.com/ahk/Notify/
#Include Notify.ahk

;####################################
; Here we have some configurations - you may change these accordingly
;####################################

; Boolean (0 or 1) to tell Spotifine if it should create/update the
; "playing_now.txt" file (which can be useful for streamers, as some
; applications rely on a file to display the current song)
CreateNowPlayingTXT := 1
; Strings to prepend or append to the "ARTIST - SONG" string
; written in the "playing_now.txt" file
NowPlayingPrefix := ""
NowPlayingSuffix := ""
; Boolean (0 or 1) to tell Spotifine if it should display the
; notification baloon when a new song is played (RECOMMENDED if you
; want to be able to block new artists/songs on the fly!)
ShowPlayingTraytip := 1
; Boolean (0 or 1) to tell Spotifine if it should display the
; notification baloon when an artist or song is blocked
ShowBlockedTraytip := 1
; Milliseconds to wait between each check (the smaller this number
; is, the more "instant" Spotifine will seem to block blacklisted
; stuff, so the recommended here is something between 25 and 60)
CheckInterval := 45

;####################################
; End of the configuration section - now go use Spotifine!
;####################################

LoadGlobalBlocklists() ; load blocked artists and songs

ProgName := "Spotifine"

Unmute() ; make sure Spotify is not muted by Spotifine on startup
glob_IsMuted := 0 ; global boolean to control the current state
glob_Dash := "–" ; this an "EN Dash", not a common keyboard hifen

SetTimer, CheckSpotify, % 0-CheckInterval

Return

;-------------------------------------------------------------------------------------------

CheckSpotify:
    If !( CurrentTitle := PlayingNow() ) {
        LastTitle := CurrentTitle
        SetTimer, CheckSpotify, % 0-CheckInterval
        Return
    }
    If ( IsBlockedArtist() && !glob_IsMuted ) {
        BlockText := "Blocked artist:`n" CurrentTitle
        GoSub, BlockAd
        Return
    }
    If ( IsBlockedSong() && !glob_IsMuted ) {
        BlockText := "Blocked song:`n" CurrentTitle
        GoSub, BlockAd
        Return
    }
    If !( CurrentTitle == LastTitle ) {
        PlayingNowString := NowPlayingPrefix RegExReplace(CurrentTitle,glob_Dash,"-") NowPlayingSuffix
        If ( CreateNowPlayingTXT ) {
            FileDelete, playing_now.txt
            FileAppend, % PlayingNowString . "     ", playing_now.txt
        }
        If ( ShowPlayingTraytip ) {
            Notify( "" , "" , 0 , "Wait=" CurrentNotifyID ) ;; kills an open notification
            CurrentNotifyID := Notify(ProgName,CurrentTitle,7,"AC=OpenBlockingWindow")
            /*
            TrayTip, %ProgName%, % CurrentTitle,, 1
            SetTimer, RemoveTrayTip, -2750
            */
        }
    }
    If glob_IsMuted
        Unmute()
    LastTitle := CurrentTitle
    SetTimer, CheckSpotify, % 0-CheckInterval
Return

;-------------------------------------------------------------------------------------------

/*
RemoveTrayTip:
    TrayTip
Return
*/

OpenBlockingWindow:
    DashPosition := InStr(CurrentTitle,glob_Dash)
    CurrentArtist := SubStr(CurrentTitle,1,DashPosition-1)
    CurrentSong := SubStr(CurrentTitle,DashPosition+1)
    Gui, 86: -Resize +ToolWindow
    Gui, 86: Add, Button, gBlockArtistButton Center x5 y5 w200 h100, % "BLOCK ARTIST:`n`n" CurrentArtist
    Gui, 86: Add, Button, gBlockSongButton Center x210 y5 w200 h100, % "BLOCK SONG:`n`n" CurrentSong
    ; Looping just to make sure, as the GUI didn't seem to show properly sometimes
    Loop, 3 {
        Gui, 86: Show, AutoSize Center
        Sleep, 50
    }
Return

;-------------------------------------------------------------------------------------------

BlockArtistButton:
BlockSongButton:
    Gui, 86: +Disabled
    If ( InStr(A_ThisLabel,"Artist") )
        FileAppend, % CurrentArtist "`n", blocked_artists.txt
    Else ;; If ( InStr(A_ThisLabel,"Song") )
        FileAppend, % CurrentSong "`n", blocked_songs.txt
    LoadGlobalBlocklists()
86GuiEscape:
86GuiClose:
    Gui, 86: Destroy
Return

;-------------------------------------------------------------------------------------------

BlockAd:
    If ShowBlockedTraytip {
        Notify( "" , "" , 0 , "Wait=" CurrentNotifyID ) ;; kills an open notification
        CurrentNotifyID := Notify(ProgName,BlockText,6)
    }
        /*
        TrayTip, %ProgName%, %BlockText%,, 2
        */
    Mute()
    /*
    SetTimer, RemoveTrayTip, -3750
    */
    SetTimer, PlayMutedAd, -10
    LastTitle := CurrentTitle
Return

;-------------------------------------------------------------------------------------------

PlayMutedAd:
    WM_KEYDOWN := 0x100
    VK_SPACE := 0x20
    ; for the next 3 seconds, make sure to "play" the
    ; muted ad in case it pauses itself
    Loop, 15 {
        If !PlayingNow()
            PostMessage, %WM_KEYDOWN%, %VK_SPACE%, 0,, ahk_class SpotifyMainWindow
        Sleep, 200
    }
    While ( IsBlockedArtist() OR IsBlockedSong() )
        Sleep, 50
    Unmute()
    ; for the next 3 seconds, make sure to play the
    ; next song in case it pauses itself
    Loop, 15 {
        If !PlayingNow()
            PostMessage, %WM_KEYDOWN%, %VK_SPACE%, 0,, ahk_class SpotifyMainWindow
        Sleep, 200
    }
    SetTimer, CheckSpotify, -10
Return

;===========================================================================================

Mute() {
    GLOBAL glob_IsMuted
    NIRCMD( glob_IsMuted := 1 )
}

;===========================================================================================

Unmute() {
    GLOBAL glob_IsMuted
    NIRCMD( glob_IsMuted := 0 )
}

;===========================================================================================

NIRCMD(Flag) { ; http://www.nirsoft.net/utils/nircmd.html
    Run, %COMSPEC% /c nircmd muteappvolume spotify.exe %Flag%,, HIDE
}

;===========================================================================================

PlayingNow() {
    WinGetTitle, SpotifyTitle, ahk_class SpotifyMainWindow
    ;Return ( InStr(SpotifyTitle,"Spotify - ") ? SubStr(SpotifyTitle,11) : "" )
    Return SubStr(SpotifyTitle,11)
}

;===========================================================================================

IsBlockedArtist() {
    GLOBAL glob_BlockArtist, glob_Dash
    CurrentTitle := PlayingNow()
    StringSplit, CurrentTitle, CurrentTitle, % glob_Dash, % " "
    Return ExactMatch(glob_BlockArtist,CurrentTitle1)
}

;===========================================================================================

IsBlockedSong() {
    GLOBAL glob_BlockSong, glob_Dash
    CurrentTitle := PlayingNow()
    StringSplit, CurrentTitle, CurrentTitle, % glob_Dash, % " "
    Return ExactMatch(glob_BlockSong,CurrentTitle2)
}

;===========================================================================================

ExactMatch(p_Haystack,p_Needle,p_Delim="`n",p_Omit=" `t`r") {
    Loop, Parse, p_Haystack, % p_Delim, % p_Omit
        if ( A_LoopField = p_Needle ) ;; default is case-insensitive check
            return 1
    return 0
}

;-------

LoadGlobalBlocklists() {
    Global glob_BlockArtist, glob_BlockSong
    FileRead, glob_BlockArtist, blocked_artists.txt
    FileRead, glob_BlockSong, blocked_songs.txt
}


;*******************************************************************************************
;*******************************************************************************************
;*** OLD STUFF (please ignore) **************
;*******************************************************************************************
;*******************************************************************************************


;#Up:: Send, {Media_Stop}
;#Down:: Send, {Media_Play_Pause}
;#Left:: Send, {Media_Prev}
;#Right:: Send, {Media_Next}
;^Up:: ControlSend, ahk_parent, {Space}, ahk_class SpotifyMainWindow


/*
    BlockInput, On
    Loop, 20
        ControlSend, ahk_parent, ^{Down}, ahk_class SpotifyMainWindow
    Loop, 3
        Send, {LCTRL UP}{LCTRL DOWN}
    BlockInput, Off
*/
/*
TOOLTIP MANDANDO
    ABAIXAR_W := 0x8080002d
    ABAIXAR_L := 0x02c802b3
    PAUSE_W := 0x80800014
    PP_L := 0074069a
    PLAY_W := 0x80800015
    WM_MENUSELECT := 0x011F
    Loop, 20
    {
        PostMessage, %WM_MENUSELECT%, %PLAY_W%, %PP_L%,, ahk_class SpotifyMainWindow
        PostMessage, %WM_MENUSELECT%, 0xffff0000, 0,, ahk_class SpotifyMainWindow
    }
SLEEP, 200
TOOLTIP
*/
/*
    WM_KEYDOWN := 0x100
    VK_CONTROL := 0x11
    VK_SPACE := 0x20
    VK_DOWN := 0x28
    PostMessage, %WM_KEYDOWN%, %VK_CONTROL%, 0,, ahk_class SpotifyMainWindow
    PostMessage, %WM_KEYDOWN%, %VK_DOWN%, 0,, ahk_class SpotifyMainWindow
*/
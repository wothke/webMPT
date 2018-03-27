# webMPT

Copyright (C) 2018 Juergen Wothke

This is a JavaScript/WebAudio plugin of "libopenmpt" . This plugin is designed to work with my generic WebAudio 
ScriptProcessor music player (see separate project) but the API exposed by the lib can be used in any 
JavaScript program (it should look familiar to anyone that has ever done some sort of music player plugin). 

I mainly added this to fill some gaps regarding formats that are not already covered by XMP or UADE (e.g. Digital Sound 
Interface Kit RIFF, Disorder Tracker 2, Mad Tracker 2, Protracker IFF, Velvet Studio, X-Tracker). But it also
plays various of the more widespread formats (I don't know how its playback quality compares to the other players).

Files that can be played include: .669, .amf, .amf, .ams, .ams, .dbm, .digi, .dmf, .dsm, .dtm, .far, .gdm, .ice, .imf, 
.it, .j2b, .m15, .mdl, .med, .mmcmp, .mms, .mo3, .mod, .mptm, .mt2, .mtm, .nst, .okt, .plm, .ppm, .psm, .pt36, .ptm, 
.s3m, .sfx, .sfx2, .st26, .stk, .stm, .stp, .ult, .umx, .wow, .xm, .xpk


Known limitations: The current implementation only supoortes 1-file songs. Songs using separate instrument 
files (etc) will not work since asynchronous load-on-demand has not been added yet here (I did not check if
respective scenarios exist).

A live demo of this program can be found here: http://www.wothke.ch/webMPT/


## Credits

The project is based on: https://lib.openmpt.org/libopenmpt/


## Project

All the "Web" specific additions (i.e. the whole point of this project) are contained in the 
"emscripten" subfolder.  The "src" folder contains all the original libopenmpt code (release 0.3.7).


## Howto build

You'll need Emscripten (http://kripken.github.io/emscripten-site/docs/getting_started/downloads.html). The make script 
is designed for use of emscripten version 1.37.29 (unless you want to create WebAssembly output, older versions might 
also still work).

The below instructions assume that the webMPT project folder has been moved into the main emscripten 
installation folder (maybe not necessary) and that a command prompt has been opened within the 
project's "emscripten" sub-folder, and that the Emscripten environment vars have been previously 
set (run emsdk_env.bat).

The Web version is then built using the makeEmscripten.bat that can be found in this folder. The 
script will compile directly into the "emscripten/htdocs" example web folder, were it will create 
the backend_mpt.js library. (To create a clean-build you have to delete any previously built libs in the 
'built' sub-folder!) The content of the "htdocs" can be tested by first copying it into some 
document folder of a web server. 

In case you want to play songs that are larger than 16Mb, you'll probably need to increase the memory 
allocated to the emulator (see TOTAL_MEMORY in makeEmscripten.bat).

This is one of the larger emulators and WASM output will significantly reduce the size. This can be enabled in the 
makeEmscripten.bat to generate WASM instead of asm.js.

## Depencencies

Recommended use of version 1.03 of my https://github.com/wothke/webaudio-player (older versions will not
support WebAssembly and the playback of remote files)

This project comes without any music files, so you'll also have to get your own and place them
in the htdocs/music folder (you can configure them in the 'songs' list in index.html).


## License

The OpenMPT code is licensed under the BSD license. The same license is extended to the code
added here to create the backend_mpt.js library.

Copyright (c) 2004-2018, OpenMPT contributors
Copyright (c) 1997-2003, Olivier Lapicque
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the OpenMPT project nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE CONTRIBUTORS ``AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

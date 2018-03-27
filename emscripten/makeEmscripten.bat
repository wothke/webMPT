::  POOR MAN'S DOS PROMPT BUILD SCRIPT.. make sure to delete the respective built/*.bc files before building!
::  existing *.bc files will not be recompiled. 

setlocal enabledelayedexpansion

SET ERRORLEVEL
VERIFY > NUL

:: **** use the "-s WASM" switch to compile WebAssembly output. warning: the SINGLE_FILE approach does NOT currently work in Chrome 63.. ****
set "OPT= -s DEMANGLE_SUPPORT=0 -s WASM=0 -s ASSERTIONS=0 -DOPENMPT_VERSION_REVISION="37" -DMPT_WITH_MINIZ -DNO_PLUGINS -DLIBOPENMPT_BUILD -s FORCE_FILESYSTEM=1 -fPIC -s PRECISE_F32=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -ffast-math -Wcast-align -fno-strict-aliasing -s VERBOSE=0 -s SAFE_HEAP=0 -s DISABLE_EXCEPTION_CATCHING=0 -D_LITTLE_ENDIAN -DMPT_COMPILER_CLANG -DHAVE_STDINT_H -DNO_DEBUG_LOGS -Wno-pointer-sign -I. -I.. -I../src -I../src/include  -I../src/common -I../src/soundbase   -Os -O3 "
if not exist "built/mini.bc" (
	call emcc.bat %OPT% ../src/include/miniz/miniz.c -o built/mini.bc
	IF !ERRORLEVEL! NEQ 0 goto :END
)
if not exist "built/common.bc" (
	call emcc.bat %OPT%  -std=c++11 ../src/common/ComponentManager.cpp ../src/common/FileReader.cpp ../src/common/Logging.cpp ../src/common/misc_util.cpp ../src/common/mptCPU.cpp ../src/common/mptFileIO.cpp ../src/common/mptIO.cpp ../src/common/mptLibrary.cpp ../src/common/mptOS.cpp ../src/common/mptPathString.cpp ../src/common/mptRandom.cpp ../src/common/mptString.cpp ../src/common/mptStringFormat.cpp ../src/common/mptStringParse.cpp ../src/common/mptTime.cpp ../src/common/mptUUID.cpp ../src/common/mptWine.cpp ../src/common/Profiler.cpp ../src/common/serialization_utils.cpp ../src/common/stdafx.cpp ../src/common/typedefs.cpp ../src/common/version.cpp -o built/common.bc
	IF !ERRORLEVEL! NEQ 0 goto :END
)
if not exist "built/sounddsp.bc" (
	call emcc.bat %OPT%  -std=c++11 ../src/sounddsp/AGC.cpp ../src/sounddsp/DSP.cpp ../src/sounddsp/EQ.cpp ../src/sounddsp/Reverb.cpp -o built/sounddsp.bc
	IF !ERRORLEVEL! NEQ 0 goto :END
)
if not exist "built/soundlib.bc" (
	call emcc.bat %OPT%  -std=c++11 ../src/soundlib/AudioCriticalSection.cpp ../src/soundlib/ContainerMMCMP.cpp ../src/soundlib/ContainerPP20.cpp ../src/soundlib/ContainerUMX.cpp ../src/soundlib/ContainerXPK.cpp ../src/soundlib/Dither.cpp ../src/soundlib/Dlsbank.cpp ../src/soundlib/Fastmix.cpp ../src/soundlib/InstrumentExtensions.cpp ../src/soundlib/ITCompression.cpp ../src/soundlib/ITTools.cpp ../src/soundlib/Load_669.cpp ../src/soundlib/Load_amf.cpp ../src/soundlib/Load_ams.cpp ../src/soundlib/Load_dbm.cpp ../src/soundlib/Load_digi.cpp ../src/soundlib/Load_dmf.cpp ../src/soundlib/Load_dsm.cpp ../src/soundlib/Load_dtm.cpp ../src/soundlib/Load_far.cpp ../src/soundlib/Load_gdm.cpp ../src/soundlib/Load_imf.cpp ../src/soundlib/Load_it.cpp ../src/soundlib/Load_itp.cpp ../src/soundlib/load_j2b.cpp ../src/soundlib/Load_mdl.cpp ../src/soundlib/Load_med.cpp ../src/soundlib/Load_mid.cpp ../src/soundlib/Load_mo3.cpp ../src/soundlib/Load_mod.cpp ../src/soundlib/Load_mt2.cpp ../src/soundlib/Load_mtm.cpp ../src/soundlib/Load_okt.cpp ../src/soundlib/Load_plm.cpp ../src/soundlib/Load_psm.cpp ../src/soundlib/Load_ptm.cpp ../src/soundlib/Load_s3m.cpp ../src/soundlib/Load_sfx.cpp ../src/soundlib/Load_stm.cpp ../src/soundlib/Load_stp.cpp ../src/soundlib/Load_uax.cpp ../src/soundlib/Load_ult.cpp ../src/soundlib/Load_wav.cpp ../src/soundlib/Load_xm.cpp ../src/soundlib/Message.cpp ../src/soundlib/MIDIEvents.cpp ../src/soundlib/MIDIMacros.cpp ../src/soundlib/MixerLoops.cpp ../src/soundlib/MixerSettings.cpp ../src/soundlib/MixFuncTable.cpp ../src/soundlib/ModChannel.cpp ../src/soundlib/modcommand.cpp ../src/soundlib/ModInstrument.cpp ../src/soundlib/ModSample.cpp ../src/soundlib/ModSequence.cpp ../src/soundlib/modsmp_ctrl.cpp ../src/soundlib/mod_specifications.cpp ../src/soundlib/MPEGFrame.cpp ../src/soundlib/OggStream.cpp ../src/soundlib/pattern.cpp ../src/soundlib/patternContainer.cpp ../src/soundlib/Paula.cpp ../src/soundlib/RowVisitor.cpp ../src/soundlib/S3MTools.cpp ../src/soundlib/SampleFormatFLAC.cpp ../src/soundlib/SampleFormatMediaFoundation.cpp ../src/soundlib/SampleFormatMP3.cpp ../src/soundlib/SampleFormatOpus.cpp ../src/soundlib/SampleFormats.cpp ../src/soundlib/SampleFormatVorbis.cpp ../src/soundlib/SampleIO.cpp ../src/soundlib/Sndfile.cpp ../src/soundlib/Sndmix.cpp ../src/soundlib/Snd_flt.cpp ../src/soundlib/Snd_fx.cpp ../src/soundlib/SoundFilePlayConfig.cpp ../src/soundlib/Tables.cpp ../src/soundlib/Tagging.cpp ../src/soundlib/tuning.cpp ../src/soundlib/tuningbase.cpp ../src/soundlib/tuningCollection.cpp ../src/soundlib/UMXTools.cpp ../src/soundlib/UpgradeModule.cpp ../src/soundlib/WAVTools.cpp ../src/soundlib/WindowedFIR.cpp ../src/soundlib/XMTools.cpp -o built/soundlib.bc
	IF !ERRORLEVEL! NEQ 0 goto :END
)
if not exist "built/libopenmpt.bc" (
	call emcc.bat %OPT%  -std=c++11 ../src/libopenmpt/libopenmpt_impl.cpp ../src/libopenmpt/libopenmpt_c.cpp ../src/libopenmpt/libopenmpt_ext_impl.cpp ../src/libopenmpt/libopenmpt_cxx.cpp -o built/libopenmpt.bc
	IF !ERRORLEVEL! NEQ 0 goto :END
)

call emcc.bat %OPT%  -std=c++11 -s TOTAL_MEMORY=67108864 --closure 1 --llvm-lto 1 --memory-init-file 0 built/mini.bc built/common.bc built/sounddsp.bc built/soundlib.bc built/libopenmpt.bc adapter.cpp  -s EXPORTED_FUNCTIONS="['_emu_setup', '_emu_init','_emu_teardown','_emu_get_current_position','_emu_seek_position','_emu_get_max_position','_emu_set_subsong','_emu_get_track_info','_emu_get_sample_rate','_emu_get_audio_buffer','_emu_get_audio_buffer_length','_emu_compute_audio_samples', '_malloc', '_free']"  -o htdocs/mpt.js  -s SINGLE_FILE=0 -s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall', 'Pointer_stringify']"  -s BINARYEN_ASYNC_COMPILATION=1 -s BINARYEN_TRAP_MODE='clamp' && copy /b shell-pre.js + htdocs\mpt.js + shell-post.js htdocs\web_mpt3.js && del htdocs\mpt.js && copy /b htdocs\web_mpt3.js + mpt_adapter.js htdocs\backend_mpt.js && del htdocs\web_mpt3.js
:END
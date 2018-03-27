/*
* This file adapts "libopenmpt" to the interface expected by my generic JavaScript player..
*
* Copyright (C) 2018 Juergen Wothke
*
* LICENSE
* 
* The code is licensed under the BSD license. 
*/

#include <emscripten.h>
#include <stdio.h>
#include <stdlib.h>     /* malloc, free, rand */

#include <exception>
#include <iostream>
#include <fstream>

#ifdef EMSCRIPTEN
#define EMSCRIPTEN_KEEPALIVE __attribute__((used))
#else
#define EMSCRIPTEN_KEEPALIVE
#endif

#define BUF_SIZE	1024
#define TEXT_MAX	255
#define NUM_MAX	15

#define CHANNELS 2				
#define BYTES_PER_SAMPLE 2
#define SAMPLE_BUF_SIZE	1024
#define SAMPLE_RATE	44100

#define t_int16   signed short
t_int16 sample_buffer[SAMPLE_BUF_SIZE * CHANNELS];
int samples_available= 0;

const char* info_texts[5];

char title_str[TEXT_MAX];
char artist_str[TEXT_MAX];
char type_str[TEXT_MAX];
char msg_str[TEXT_MAX];
char tracker_str[TEXT_MAX];


#include "../src/libopenmpt/libopenmpt.h"
#include "../src/libopenmpt/libopenmpt.hpp"


struct StaticBlock {
    StaticBlock(){
		info_texts[0]= title_str;
		info_texts[1]= artist_str;
		info_texts[2]= type_str;
		info_texts[3]= msg_str;
		info_texts[4]= tracker_str;
    }
};
	
void meta_clear() {
	snprintf(title_str, TEXT_MAX, "");
	snprintf(artist_str, TEXT_MAX, "");
	snprintf(type_str, TEXT_MAX, "");
	snprintf(msg_str, TEXT_MAX, "");
	snprintf(tracker_str, TEXT_MAX, "");
}


static StaticBlock g_emscripen_info;

openmpt_module *module= 0;
void *fileBuf= 0;


extern "C" void emu_teardown (void)  __attribute__((noinline));
extern "C" void EMSCRIPTEN_KEEPALIVE emu_teardown (void) {
	if (fileBuf) {
		free(fileBuf);
		fileBuf= 0;
	}
	
	if (module) {
		openmpt_module_destroy(module);
		module= 0;
	}
}

extern "C" int emu_setup(char *unused) __attribute__((noinline));
extern "C" EMSCRIPTEN_KEEPALIVE int emu_setup(char *unused)
{
	return 0;
}

void update_song_info() {
	meta_clear();

	if (module) {
		int32_t subsong= openmpt_module_get_selected_subsong( module );
		snprintf(title_str, TEXT_MAX, "%s", openmpt_module_get_metadata( module, "title" ));
		snprintf(artist_str, TEXT_MAX, "%s", openmpt_module_get_metadata( module, "artist" ));
		snprintf(type_str, TEXT_MAX, "%s", openmpt_module_get_metadata( module, "type_long" ));
		snprintf(msg_str, TEXT_MAX, "%s", openmpt_module_get_metadata( module, "message" ));
		snprintf(tracker_str, TEXT_MAX, "%s", openmpt_module_get_metadata( module, "tracker" ));		
	}
}

extern "C" int emu_init(char *basedir, char *songmodule, void *filedata, int len) __attribute__((noinline));
extern "C" EMSCRIPTEN_KEEPALIVE int emu_init(char *basedir, char *songmodule, void *filedata, int len)
{
	emu_teardown();

	fileBuf= malloc(len);
	memcpy(fileBuf, filedata, len);
	
	/* pointless check - see ".ams" which is actually supported
	std::string ext = songmodule;
	ext.substr(ext.find_last_of(".") + 1);
	if (!openmpt_is_extension_supported(ext.c_str())) { 
		return 1; 
	}
	*/ 
	// openmpt_log_func_default / openmpt_log_func_silent
	module= openmpt_module_create_from_memory( (const void *) fileBuf, len, openmpt_log_func_default, NULL, NULL );
	if (!module) {
		return 1;
	}
	return 0;
}

extern "C" int emu_get_sample_rate() __attribute__((noinline));
extern "C" EMSCRIPTEN_KEEPALIVE int emu_get_sample_rate()
{
	return SAMPLE_RATE;
}

extern "C" int emu_set_subsong(int subsong, unsigned char boost) __attribute__((noinline));
extern "C" int EMSCRIPTEN_KEEPALIVE emu_set_subsong(int subsong, unsigned char boost) {
	
	if (subsong >= 0) openmpt_module_select_subsong( module, subsong );	

	update_song_info();
	
	return 0;
}

extern "C" const char** emu_get_track_info() __attribute__((noinline));
extern "C" const char** EMSCRIPTEN_KEEPALIVE emu_get_track_info() {
	return info_texts;
}

extern "C" char* EMSCRIPTEN_KEEPALIVE emu_get_audio_buffer(void) __attribute__((noinline));
extern "C" char* EMSCRIPTEN_KEEPALIVE emu_get_audio_buffer(void) {
	return (char*)sample_buffer;
}

extern "C" long EMSCRIPTEN_KEEPALIVE emu_get_audio_buffer_length(void) __attribute__((noinline));
extern "C" long EMSCRIPTEN_KEEPALIVE emu_get_audio_buffer_length(void) {
	return samples_available;
}

extern "C" int emu_compute_audio_samples() __attribute__((noinline));
extern "C" int EMSCRIPTEN_KEEPALIVE emu_compute_audio_samples() {
	samples_available= module ? openmpt_module_read_interleaved_stereo( module, SAMPLE_RATE, SAMPLE_BUF_SIZE, (int16_t *) sample_buffer ) : 0;

	if (samples_available == 0) {
		return 1;
	}
	return 0;
}

extern "C" int emu_get_current_position() __attribute__((noinline));
extern "C" int EMSCRIPTEN_KEEPALIVE emu_get_current_position() {
	return module ? openmpt_module_get_position_seconds( module )*1000 : 0;
}

extern "C" void emu_seek_position(int pos) __attribute__((noinline));
extern "C" void EMSCRIPTEN_KEEPALIVE emu_seek_position(int ms) {
//	gsf_seek_position(ms);
}

extern "C" int emu_get_max_position() __attribute__((noinline));
extern "C" int EMSCRIPTEN_KEEPALIVE emu_get_max_position() {
	return module ? openmpt_module_get_duration_seconds( module )*1000 : -1;	//ms
}


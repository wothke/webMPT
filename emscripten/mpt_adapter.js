/*
 mpt_adapter.js: Adapts "libopenmpt" backend to generic WebAudio/ScriptProcessor player.
 
 version 1.0
 
 	Copyright (C) 2018 Juergen Wothke

 LICENSE
    The code is licensed under the BSD license. 
*/

MPTBackendAdapter = (function(){ var $this = function () {
		$this.base.call(this, backend_mpt.Module, 2);
		this._manualSetupComplete= true;
		this._undefined;
		this._currentPath;
		this._currentFile;
		
		this._scopeEnabled= false;

		if (!backend_mpt.Module.notReady) {
			// in sync scenario the "onRuntimeInitialized" has already fired before execution gets here,
			// i.e. it has to be called explicitly here (in async scenario "onRuntimeInitialized" will trigger
			// the call directly)
			this.doOnAdapterReady();
		}				
	}; 
	// sample buffer contains 2-byte integer sample data (i.e. 
	// must be rescaled) of 2 interleaved channels
	extend(EmsHEAP16BackendAdapter, $this, {
		enableScope: function(enable) {
			this._scopeEnabled= enable;
		},		
		doOnAdapterReady: function() {
			// called when runtime is ready (e.g. asynchronously when WASM is loaded)
			// if FS needed to be setup of would be done here..
		},
		getAudioBuffer: function() {
			var ptr=  this.Module.ccall('emu_get_audio_buffer', 'number');			
			// make it a this.Module.HEAP16 pointer
			return ptr >> 1;	// 2 x 16 bit samples			
		},
		getAudioBufferLength: function() {
			var len= this.Module.ccall('emu_get_audio_buffer_length', 'number');
			return len;
		},
		computeAudioSamples: function() {
			return this.Module.ccall('emu_compute_audio_samples', 'number');
		},
		getMaxPlaybackPosition: function() { 
			return this.Module.ccall('emu_get_max_position', 'number');
		},
		getPlaybackPosition: function() {
			return this.Module.ccall('emu_get_current_position', 'number');
		},
		seekPlaybackPosition: function(pos) {
			var current= this.getPlaybackPosition();
			if (pos < current) {
				// hack: for some reason backward seeking fails ('he: execution error') if "built-in"
				// file reload if used... 
				var ret = this.Module.ccall('emu_init', 'number', 
							['string', 'string'], 
							[ this._currentPath, this._currentFile]);
			}
			var v= ScriptNodePlayer.getInstance().getVolume();
			ScriptNodePlayer.getInstance().setVolume(0);	// suppress any output while reset is in progress
			this.Module.ccall('emu_seek_position', 'number', ['number'], [pos]);
			ScriptNodePlayer.getInstance().setVolume(v);
		},
		/*
		* Creates the URL used to retrieve the song file.
		*/
		mapUrl: function(filename) {			
			// used transform the "internal filename" to a valid URL
			var uri= this.mapFs2Uri(filename);
			return uri;
		},
		mapInternalFilename: function(overridePath, basePath, filename) {
			//map URLSs to FS			
			filename= this.mapUri2Fs(filename);	// treat all songs as "from outside"

			var f= ((overridePath)?overridePath:basePath) + filename;	// this._basePath ever needed?			
			return f;
		},
		
		getPathAndFilename: function(filename) {
			var sp = filename.split('/');
			var fn = sp[sp.length-1];					
			var path= filename.substring(0, filename.lastIndexOf("/"));	
			if (path.lenght) path= path+"/";
			
			return [path, fn];
		},
		
		mapBackendFilename: function (name) {
			// "name" comes from the C++ side 
			var input= this.Module.Pointer_stringify(name);
			return input;
		},
		registerFileData: function(pathFilenameArray, data) {
			// input: the path is fixed to the basePath & the filename is actually still a path+filename
			var path= pathFilenameArray[0];
			var filename= pathFilenameArray[1];

			// MANDATORTY to move any path info still present in the "filename" to "path"
			var tmpPathFilenameArray = new Array(2);	// do not touch original IO param			
			var p= filename.lastIndexOf("/");
			if (p > 0) {
				tmpPathFilenameArray[0]= path + filename.substring(0, p);
				tmpPathFilenameArray[1]= filename.substring(p+1);
			} else  {
				tmpPathFilenameArray[0]= path;
				tmpPathFilenameArray[1]= filename;
			}
			// setup data in our virtual FS (the next access should then be OK)
			return this.registerEmscriptenFileData(tmpPathFilenameArray, data);
		},
		loadMusicData: function(sampleRate, path, filename, data, options) {
			var buf = this.Module._malloc(data.length);
			this.Module.HEAPU8.set(data, buf);

			var ret = this.Module.ccall('emu_init', 'number', 
								['string', 'string',  'number',  'number'], 
								[ path, filename, buf, data.length]);
			this.Module._free(buf);

			if (ret == 0) {
				var inputSampleRate = this.Module.ccall('emu_get_sample_rate', 'number');
				this.resetSampleRate(sampleRate, inputSampleRate); 
				this._currentPath= path;
				this._currentFile= filename;
			} else {
				this._currentPath= this._undefined;
				this._currentFile= this._undefined;
			}
			return ret;
		},
		evalTrackOptions: function(options) {
			// is there any scenario with subsongs?
			if (typeof options.timeout != 'undefined') {
				ScriptNodePlayer.getInstance().setPlaybackTimeout(options.timeout*1000);
			}
			var id= (options && options.track) ? options.track : 0;		
			var boostVolume= (options && options.boostVolume) ? options.boostVolume : 0;		
			return this.Module.ccall('emu_set_subsong', 'number', ['number', 'number'], [id, boostVolume]);
		},				
		teardown: function() {
			this.Module.ccall('emu_teardown', 'number');	// just in case
		},
		getSongInfoMeta: function() {
			return {title: String,
					artist: String, 
					type: String, 
					msg: String, 
					tracker: String,
					tracks: String,
					};
		},
	
		updateSongInfo: function(filename, result) {
			var numAttr= 6;
			var ret = this.Module.ccall('emu_get_track_info', 'number');

			var array = this.Module.HEAP32.subarray(ret>>2, (ret>>2)+numAttr);
			result.title= this.Module.Pointer_stringify(array[0]);
			if (!result.title.length) result.title= filename.replace(/^.*[\\\/]/, '');		
			result.artist= this.Module.Pointer_stringify(array[1]);		
			result.type= this.Module.Pointer_stringify(array[2]);
			result.msg= this.Module.Pointer_stringify(array[3]);
			result.tracker= this.Module.Pointer_stringify(array[4]);
			result.tracks= this.Module.Pointer_stringify(array[5]);
		},
		// To activate the below output a song must be started with the "enableScope()"
		// At any given moment the below getters will then correspond to the output of getAudioBuffer
		// and what has last been generated by computeAudioSamples. 
		getNumberTraceStreams: function() {
			return this.Module.ccall('emu_number_trace_streams', 'number');			
		},
		getTraceStreams: function() {
			var result= [];
			var n= this.getNumberTraceStreams();

			var ret = this.Module.ccall('emu_trace_streams', 'number');			
			var array = this.Module.HEAP32.subarray(ret>>2, (ret>>2)+n);
			
			for (var i= 0; i<n; i++) {
				result.push(array[i] >> 2);	// pointer to int32 array
			}
			return result;
		},

		readFloatTrace: function(buffer, idx) {
			// input range is actually 16bit but with 9 or even 18 channels (which are added to create the final signal)
			// only a subrange is typically used (to avoid overflows) and the used scaling seems about OK to create 
			// graphs..
			return  this.Module.HEAP32[buffer+idx]/0x8000;		
		},
	});	return $this; })();
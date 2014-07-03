# SoLoud wrapper for Ruby
# This file is autogenerated; any changes will be overwritten

require "dl/import"

module SoLoudImporter
	extend DL::Importer
	dlload 'soloud_x86.dll'

	# Enumerations
	FFTFILTER_OVER=0
	SOLOUD_WASAPI=6
	SOLOUD_AUTO=0
	BIQUADRESONANTFILTER_NONE=0
	SOLOUD_CLIP_ROUNDOFF=1
	LOFIFILTER_BITDEPTH=2
	SOLOUD_SDL2=2
	SFXR_HURT=4
	FFTFILTER_MULTIPLY=2
	SOLOUD_ENABLE_VISUALIZATION=2
	BIQUADRESONANTFILTER_HIGHPASS=2
	SFXR_LASER=1
	SFXR_BLIP=6
	SFXR_JUMP=5
	LOFIFILTER_WET=0
	BIQUADRESONANTFILTER_WET=0
	LOFIFILTER_SAMPLERATE=1
	SOLOUD_SDL=1
	BIQUADRESONANTFILTER_LOWPASS=1
	SFXR_COIN=0
	FLANGERFILTER_FREQ=2
	SOLOUD_PORTAUDIO=3
	BIQUADRESONANTFILTER_SAMPLERATE=1
	SFXR_EXPLOSION=2
	BIQUADRESONANTFILTER_BANDPASS=3
	SOLOUD_OPENAL=8
	FLANGERFILTER_WET=0
	BIQUADRESONANTFILTER_FREQUENCY=2
	SFXR_POWERUP=3
	FFTFILTER_SUBTRACT=1
	SOLOUD_BACKEND_MAX=9
	BIQUADRESONANTFILTER_RESONANCE=3
	SOLOUD_XAUDIO2=5
	FLANGERFILTER_DELAY=1
	SOLOUD_WINMM=4
	SOLOUD_OSS=7

	# Raw DLL functions
	extern "void Soloud_destroy(Soloud *)"
	extern "Soloud * Soloud_create()"
	extern "int Soloud_init(Soloud *)"
	extern "int Soloud_initEx(Soloud *, unsigned int, unsigned int, unsigned int, unsigned int)"
	extern "void Soloud_deinit(Soloud *)"
	extern "unsigned int Soloud_getVersion(Soloud *)"
	extern "const char * Soloud_getErrorString(Soloud *, int)"
	extern "unsigned int Soloud_play(Soloud *, AudioSource *)"
	extern "unsigned int Soloud_playEx(Soloud *, AudioSource *, float, float, int, unsigned int)"
	extern "unsigned int Soloud_playClocked(Soloud *, double, AudioSource *)"
	extern "unsigned int Soloud_playClockedEx(Soloud *, double, AudioSource *, float, float, unsigned int)"
	extern "void Soloud_seek(Soloud *, unsigned int, double)"
	extern "void Soloud_stop(Soloud *, unsigned int)"
	extern "void Soloud_stopAll(Soloud *)"
	extern "void Soloud_stopAudioSource(Soloud *, AudioSource *)"
	extern "void Soloud_setFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int, float)"
	extern "float Soloud_getFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int)"
	extern "void Soloud_fadeFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int, float, double)"
	extern "void Soloud_oscillateFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int, float, float, double)"
	extern "double Soloud_getStreamTime(Soloud *, unsigned int)"
	extern "int Soloud_getPause(Soloud *, unsigned int)"
	extern "float Soloud_getVolume(Soloud *, unsigned int)"
	extern "float Soloud_getPan(Soloud *, unsigned int)"
	extern "float Soloud_getSamplerate(Soloud *, unsigned int)"
	extern "int Soloud_getProtectVoice(Soloud *, unsigned int)"
	extern "unsigned int Soloud_getActiveVoiceCount(Soloud *)"
	extern "int Soloud_isValidVoiceHandle(Soloud *, unsigned int)"
	extern "float Soloud_getRelativePlaySpeed(Soloud *, unsigned int)"
	extern "float Soloud_getPostClipScaler(Soloud *)"
	extern "float Soloud_getGlobalVolume(Soloud *)"
	extern "void Soloud_setGlobalVolume(Soloud *, float)"
	extern "void Soloud_setPostClipScaler(Soloud *, float)"
	extern "void Soloud_setPause(Soloud *, unsigned int, int)"
	extern "void Soloud_setPauseAll(Soloud *, int)"
	extern "void Soloud_setRelativePlaySpeed(Soloud *, unsigned int, float)"
	extern "void Soloud_setProtectVoice(Soloud *, unsigned int, int)"
	extern "void Soloud_setSamplerate(Soloud *, unsigned int, float)"
	extern "void Soloud_setPan(Soloud *, unsigned int, float)"
	extern "void Soloud_setPanAbsolute(Soloud *, unsigned int, float, float)"
	extern "void Soloud_setVolume(Soloud *, unsigned int, float)"
	extern "void Soloud_setDelaySamples(Soloud *, unsigned int, unsigned int)"
	extern "void Soloud_fadeVolume(Soloud *, unsigned int, float, double)"
	extern "void Soloud_fadePan(Soloud *, unsigned int, float, double)"
	extern "void Soloud_fadeRelativePlaySpeed(Soloud *, unsigned int, float, double)"
	extern "void Soloud_fadeGlobalVolume(Soloud *, float, double)"
	extern "void Soloud_schedulePause(Soloud *, unsigned int, double)"
	extern "void Soloud_scheduleStop(Soloud *, unsigned int, double)"
	extern "void Soloud_oscillateVolume(Soloud *, unsigned int, float, float, double)"
	extern "void Soloud_oscillatePan(Soloud *, unsigned int, float, float, double)"
	extern "void Soloud_oscillateRelativePlaySpeed(Soloud *, unsigned int, float, float, double)"
	extern "void Soloud_oscillateGlobalVolume(Soloud *, float, float, double)"
	extern "void Soloud_setGlobalFilter(Soloud *, unsigned int, Filter *)"
	extern "void Soloud_setVisualizationEnable(Soloud *, int)"
	extern "float * Soloud_calcFFT(Soloud *)"
	extern "float * Soloud_getWave(Soloud *)"
	extern "unsigned int Soloud_getLoopCount(Soloud *, unsigned int)"
	extern "unsigned int Soloud_createVoiceGroup(Soloud *)"
	extern "int Soloud_destroyVoiceGroup(Soloud *, unsigned int)"
	extern "int Soloud_addVoiceToGroup(Soloud *, unsigned int, unsigned int)"
	extern "int Soloud_isVoiceGroup(Soloud *, unsigned int)"
	extern "int Soloud_isVoiceGroupEmpty(Soloud *, unsigned int)"
	extern "void BiquadResonantFilter_destroy(BiquadResonantFilter *)"
	extern "BiquadResonantFilter * BiquadResonantFilter_create()"
	extern "int BiquadResonantFilter_setParams(BiquadResonantFilter *, int, float, float, float)"
	extern "void Bus_destroy(Bus *)"
	extern "Bus * Bus_create()"
	extern "void Bus_setFilter(Bus *, unsigned int, Filter *)"
	extern "unsigned int Bus_play(Bus *, AudioSource *)"
	extern "unsigned int Bus_playEx(Bus *, AudioSource *, float, float, int)"
	extern "unsigned int Bus_playClocked(Bus *, double, AudioSource *)"
	extern "unsigned int Bus_playClockedEx(Bus *, double, AudioSource *, float, float)"
	extern "void Bus_setVisualizationEnable(Bus *, int)"
	extern "float * Bus_calcFFT(Bus *)"
	extern "float * Bus_getWave(Bus *)"
	extern "void Bus_setLooping(Bus *, int)"
	extern "void Bus_stop(Bus *)"
	extern "void EchoFilter_destroy(EchoFilter *)"
	extern "EchoFilter * EchoFilter_create()"
	extern "int EchoFilter_setParams(EchoFilter *, float)"
	extern "int EchoFilter_setParamsEx(EchoFilter *, float, float, float)"
	extern "void FFTFilter_destroy(FFTFilter *)"
	extern "FFTFilter * FFTFilter_create()"
	extern "int FFTFilter_setParameters(FFTFilter *, int)"
	extern "int FFTFilter_setParametersEx(FFTFilter *, int, int, float)"
	extern "void FlangerFilter_destroy(FlangerFilter *)"
	extern "FlangerFilter * FlangerFilter_create()"
	extern "int FlangerFilter_setParams(FlangerFilter *, float, float)"
	extern "void LofiFilter_destroy(LofiFilter *)"
	extern "LofiFilter * LofiFilter_create()"
	extern "int LofiFilter_setParams(LofiFilter *, float, float)"
	extern "void Modplug_destroy(Modplug *)"
	extern "Modplug * Modplug_create()"
	extern "int Modplug_load(Modplug *, const char *)"
	extern "void Modplug_setLooping(Modplug *, int)"
	extern "void Modplug_setFilter(Modplug *, unsigned int, Filter *)"
	extern "void Modplug_stop(Modplug *)"
	extern "void Prg_destroy(Prg *)"
	extern "Prg * Prg_create()"
	extern "unsigned int Prg_rand(Prg *)"
	extern "void Prg_srand(Prg *, int)"
	extern "void Sfxr_destroy(Sfxr *)"
	extern "Sfxr * Sfxr_create()"
	extern "void Sfxr_resetParams(Sfxr *)"
	extern "int Sfxr_loadParams(Sfxr *, const char *)"
	extern "int Sfxr_loadPreset(Sfxr *, int, int)"
	extern "void Sfxr_setLooping(Sfxr *, int)"
	extern "void Sfxr_setFilter(Sfxr *, unsigned int, Filter *)"
	extern "void Sfxr_stop(Sfxr *)"
	extern "void Speech_destroy(Speech *)"
	extern "Speech * Speech_create()"
	extern "int Speech_setText(Speech *, const char *)"
	extern "void Speech_setLooping(Speech *, int)"
	extern "void Speech_setFilter(Speech *, unsigned int, Filter *)"
	extern "void Speech_stop(Speech *)"
	extern "void Wav_destroy(Wav *)"
	extern "Wav * Wav_create()"
	extern "int Wav_load(Wav *, const char *)"
	extern "int Wav_loadMem(Wav *, unsigned char *, unsigned int)"
	extern "double Wav_getLength(Wav *)"
	extern "void Wav_setLooping(Wav *, int)"
	extern "void Wav_setFilter(Wav *, unsigned int, Filter *)"
	extern "void Wav_stop(Wav *)"
	extern "void WavStream_destroy(WavStream *)"
	extern "WavStream * WavStream_create()"
	extern "int WavStream_load(WavStream *, const char *)"
	extern "double WavStream_getLength(WavStream *)"
	extern "void WavStream_setLooping(WavStream *, int)"
	extern "void WavStream_setFilter(WavStream *, unsigned int, Filter *)"
	extern "void WavStream_stop(WavStream *)"
end


# OOP wrappers

class Soloud
	@objhandle=nil
	attr_accessor :objhandle
	WASAPI=6
	AUTO=0
	CLIP_ROUNDOFF=1
	SDL2=2
	ENABLE_VISUALIZATION=2
	SDL=1
	PORTAUDIO=3
	OPENAL=8
	BACKEND_MAX=9
	XAUDIO2=5
	WINMM=4
	OSS=7
	def initialize(args)
		@objhandle = SoLoudImporter.Soloud_create()
	end
	def destroy()
		SoLoudImporter.Soloud_destroy(@objhandle)
	end
	def init(aFlags=CLIP_ROUNDOFF, aBackend=AUTO, aSamplerate=AUTO, aBufferSize=AUTO)
		SoLoudImporter.Soloud_initEx(@objhandle, aFlags, aBackend, aSamplerate, aBufferSize)
	end
	def deinit()
		SoLoudImporter.Soloud_deinit(@objhandle)
	end
	def get_version()
		SoLoudImporter.Soloud_getVersion(@objhandle)
	end
	def get_error_string(aErrorCode)
		SoLoudImporter.Soloud_getErrorString(@objhandle, aErrorCode)
	end
	def play(aSound, aVolume=1.0, aPan=0.0, aPaused=0, aBus=0)
		SoLoudImporter.Soloud_playEx(@objhandle, aSound.objhandle, aVolume, aPan, aPaused, aBus)
	end
	def play_clocked(aSoundTime, aSound, aVolume=1.0, aPan=0.0, aBus=0)
		SoLoudImporter.Soloud_playClockedEx(@objhandle, aSoundTime, aSound.objhandle, aVolume, aPan, aBus)
	end
	def seek(aVoiceHandle, aSeconds)
		SoLoudImporter.Soloud_seek(@objhandle, aVoiceHandle, aSeconds)
	end
	def stop(aVoiceHandle)
		SoLoudImporter.Soloud_stop(@objhandle, aVoiceHandle)
	end
	def stop_all()
		SoLoudImporter.Soloud_stopAll(@objhandle)
	end
	def stop_audio_source(aSound)
		SoLoudImporter.Soloud_stopAudioSource(@objhandle, aSound.objhandle)
	end
	def set_filter_parameter(aVoiceHandle, aFilterId, aAttributeId, aValue)
		SoLoudImporter.Soloud_setFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId, aValue)
	end
	def get_filter_parameter(aVoiceHandle, aFilterId, aAttributeId)
		SoLoudImporter.Soloud_getFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId)
	end
	def fade_filter_parameter(aVoiceHandle, aFilterId, aAttributeId, aTo, aTime)
		SoLoudImporter.Soloud_fadeFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId, aTo, aTime)
	end
	def oscillate_filter_parameter(aVoiceHandle, aFilterId, aAttributeId, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId, aFrom, aTo, aTime)
	end
	def get_stream_time(aVoiceHandle)
		SoLoudImporter.Soloud_getStreamTime(@objhandle, aVoiceHandle)
	end
	def get_pause(aVoiceHandle)
		SoLoudImporter.Soloud_getPause(@objhandle, aVoiceHandle)
	end
	def get_volume(aVoiceHandle)
		SoLoudImporter.Soloud_getVolume(@objhandle, aVoiceHandle)
	end
	def get_pan(aVoiceHandle)
		SoLoudImporter.Soloud_getPan(@objhandle, aVoiceHandle)
	end
	def get_samplerate(aVoiceHandle)
		SoLoudImporter.Soloud_getSamplerate(@objhandle, aVoiceHandle)
	end
	def get_protect_voice(aVoiceHandle)
		SoLoudImporter.Soloud_getProtectVoice(@objhandle, aVoiceHandle)
	end
	def get_active_voice_count()
		SoLoudImporter.Soloud_getActiveVoiceCount(@objhandle)
	end
	def is_valid_voice_handle(aVoiceHandle)
		SoLoudImporter.Soloud_isValidVoiceHandle(@objhandle, aVoiceHandle)
	end
	def get_relative_play_speed(aVoiceHandle)
		SoLoudImporter.Soloud_getRelativePlaySpeed(@objhandle, aVoiceHandle)
	end
	def get_post_clip_scaler()
		SoLoudImporter.Soloud_getPostClipScaler(@objhandle)
	end
	def get_global_volume()
		SoLoudImporter.Soloud_getGlobalVolume(@objhandle)
	end
	def set_global_volume(aVolume)
		SoLoudImporter.Soloud_setGlobalVolume(@objhandle, aVolume)
	end
	def set_post_clip_scaler(aScaler)
		SoLoudImporter.Soloud_setPostClipScaler(@objhandle, aScaler)
	end
	def set_pause(aVoiceHandle, aPause)
		SoLoudImporter.Soloud_setPause(@objhandle, aVoiceHandle, aPause)
	end
	def set_pause_all(aPause)
		SoLoudImporter.Soloud_setPauseAll(@objhandle, aPause)
	end
	def set_relative_play_speed(aVoiceHandle, aSpeed)
		SoLoudImporter.Soloud_setRelativePlaySpeed(@objhandle, aVoiceHandle, aSpeed)
	end
	def set_protect_voice(aVoiceHandle, aProtect)
		SoLoudImporter.Soloud_setProtectVoice(@objhandle, aVoiceHandle, aProtect)
	end
	def set_samplerate(aVoiceHandle, aSamplerate)
		SoLoudImporter.Soloud_setSamplerate(@objhandle, aVoiceHandle, aSamplerate)
	end
	def set_pan(aVoiceHandle, aPan)
		SoLoudImporter.Soloud_setPan(@objhandle, aVoiceHandle, aPan)
	end
	def set_pan_absolute(aVoiceHandle, aLVolume, aRVolume)
		SoLoudImporter.Soloud_setPanAbsolute(@objhandle, aVoiceHandle, aLVolume, aRVolume)
	end
	def set_volume(aVoiceHandle, aVolume)
		SoLoudImporter.Soloud_setVolume(@objhandle, aVoiceHandle, aVolume)
	end
	def set_delay_samples(aVoiceHandle, aSamples)
		SoLoudImporter.Soloud_setDelaySamples(@objhandle, aVoiceHandle, aSamples)
	end
	def fade_volume(aVoiceHandle, aTo, aTime)
		SoLoudImporter.Soloud_fadeVolume(@objhandle, aVoiceHandle, aTo, aTime)
	end
	def fade_pan(aVoiceHandle, aTo, aTime)
		SoLoudImporter.Soloud_fadePan(@objhandle, aVoiceHandle, aTo, aTime)
	end
	def fade_relative_play_speed(aVoiceHandle, aTo, aTime)
		SoLoudImporter.Soloud_fadeRelativePlaySpeed(@objhandle, aVoiceHandle, aTo, aTime)
	end
	def fade_global_volume(aTo, aTime)
		SoLoudImporter.Soloud_fadeGlobalVolume(@objhandle, aTo, aTime)
	end
	def schedule_pause(aVoiceHandle, aTime)
		SoLoudImporter.Soloud_schedulePause(@objhandle, aVoiceHandle, aTime)
	end
	def schedule_stop(aVoiceHandle, aTime)
		SoLoudImporter.Soloud_scheduleStop(@objhandle, aVoiceHandle, aTime)
	end
	def oscillate_volume(aVoiceHandle, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateVolume(@objhandle, aVoiceHandle, aFrom, aTo, aTime)
	end
	def oscillate_pan(aVoiceHandle, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillatePan(@objhandle, aVoiceHandle, aFrom, aTo, aTime)
	end
	def oscillate_relative_play_speed(aVoiceHandle, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateRelativePlaySpeed(@objhandle, aVoiceHandle, aFrom, aTo, aTime)
	end
	def oscillate_global_volume(aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateGlobalVolume(@objhandle, aFrom, aTo, aTime)
	end
	def set_global_filter(aFilterId, aFilter)
		SoLoudImporter.Soloud_setGlobalFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def set_visualization_enable(aEnable)
		SoLoudImporter.Soloud_setVisualizationEnable(@objhandle, aEnable)
	end
	def calc_fft()
		SoLoudImporter.Soloud_calcFFT(@objhandle)
	end
	def get_wave()
		SoLoudImporter.Soloud_getWave(@objhandle)
	end
	def get_loop_count(aVoiceHandle)
		SoLoudImporter.Soloud_getLoopCount(@objhandle, aVoiceHandle)
	end
	def create_voice_group()
		SoLoudImporter.Soloud_createVoiceGroup(@objhandle)
	end
	def destroy_voice_group(aVoiceGroupHandle)
		SoLoudImporter.Soloud_destroyVoiceGroup(@objhandle, aVoiceGroupHandle)
	end
	def add_voice_to_group(aVoiceGroupHandle, aVoiceHandle)
		SoLoudImporter.Soloud_addVoiceToGroup(@objhandle, aVoiceGroupHandle, aVoiceHandle)
	end
	def is_voice_group(aVoiceGroupHandle)
		SoLoudImporter.Soloud_isVoiceGroup(@objhandle, aVoiceGroupHandle)
	end
	def is_voice_group_empty(aVoiceGroupHandle)
		SoLoudImporter.Soloud_isVoiceGroupEmpty(@objhandle, aVoiceGroupHandle)
	end
end

class BiquadResonantFilter
	@objhandle=nil
	attr_accessor :objhandle
	NONE=0
	HIGHPASS=2
	WET=0
	LOWPASS=1
	SAMPLERATE=1
	BANDPASS=3
	FREQUENCY=2
	RESONANCE=3
	def initialize(args)
		@objhandle = SoLoudImporter.BiquadResonantFilter_create()
	end
	def destroy()
		SoLoudImporter.BiquadResonantFilter_destroy(@objhandle)
	end
	def set_params(aType, aSampleRate, aFrequency, aResonance)
		SoLoudImporter.BiquadResonantFilter_setParams(@objhandle, aType, aSampleRate, aFrequency, aResonance)
	end
end

class Bus
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.Bus_create()
	end
	def destroy()
		SoLoudImporter.Bus_destroy(@objhandle)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Bus_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def play(aSound, aVolume=1.0, aPan=0.0, aPaused=0)
		SoLoudImporter.Bus_playEx(@objhandle, aSound.objhandle, aVolume, aPan, aPaused)
	end
	def play_clocked(aSoundTime, aSound, aVolume=1.0, aPan=0.0)
		SoLoudImporter.Bus_playClockedEx(@objhandle, aSoundTime, aSound.objhandle, aVolume, aPan)
	end
	def set_visualization_enable(aEnable)
		SoLoudImporter.Bus_setVisualizationEnable(@objhandle, aEnable)
	end
	def calc_fft()
		SoLoudImporter.Bus_calcFFT(@objhandle)
	end
	def get_wave()
		SoLoudImporter.Bus_getWave(@objhandle)
	end
	def set_looping(aLoop)
		SoLoudImporter.Bus_setLooping(@objhandle, aLoop)
	end
	def stop()
		SoLoudImporter.Bus_stop(@objhandle)
	end
end

class EchoFilter
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.EchoFilter_create()
	end
	def destroy()
		SoLoudImporter.EchoFilter_destroy(@objhandle)
	end
	def set_params(aDelay, aDecay=0.7, aFilter=0.0)
		SoLoudImporter.EchoFilter_setParamsEx(@objhandle, aDelay, aDecay, aFilter)
	end
end

class FFTFilter
	@objhandle=nil
	attr_accessor :objhandle
	OVER=0
	MULTIPLY=2
	SUBTRACT=1
	def initialize(args)
		@objhandle = SoLoudImporter.FFTFilter_create()
	end
	def destroy()
		SoLoudImporter.FFTFilter_destroy(@objhandle)
	end
	def set_parameters(aShift, aCombine=0, aScale=0.002)
		SoLoudImporter.FFTFilter_setParametersEx(@objhandle, aShift, aCombine, aScale)
	end
end

class FlangerFilter
	@objhandle=nil
	attr_accessor :objhandle
	FREQ=2
	WET=0
	DELAY=1
	def initialize(args)
		@objhandle = SoLoudImporter.FlangerFilter_create()
	end
	def destroy()
		SoLoudImporter.FlangerFilter_destroy(@objhandle)
	end
	def set_params(aDelay, aFreq)
		SoLoudImporter.FlangerFilter_setParams(@objhandle, aDelay, aFreq)
	end
end

class LofiFilter
	@objhandle=nil
	attr_accessor :objhandle
	BITDEPTH=2
	WET=0
	SAMPLERATE=1
	def initialize(args)
		@objhandle = SoLoudImporter.LofiFilter_create()
	end
	def destroy()
		SoLoudImporter.LofiFilter_destroy(@objhandle)
	end
	def set_params(aSampleRate, aBitdepth)
		SoLoudImporter.LofiFilter_setParams(@objhandle, aSampleRate, aBitdepth)
	end
end

class Modplug
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.Modplug_create()
	end
	def destroy()
		SoLoudImporter.Modplug_destroy(@objhandle)
	end
	def load(aFilename)
		SoLoudImporter.Modplug_load(@objhandle, aFilename)
	end
	def set_looping(aLoop)
		SoLoudImporter.Modplug_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Modplug_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Modplug_stop(@objhandle)
	end
end

class Prg
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.Prg_create()
	end
	def destroy()
		SoLoudImporter.Prg_destroy(@objhandle)
	end
	def rand()
		SoLoudImporter.Prg_rand(@objhandle)
	end
	def srand(aSeed)
		SoLoudImporter.Prg_srand(@objhandle, aSeed)
	end
end

class Sfxr
	@objhandle=nil
	attr_accessor :objhandle
	HURT=4
	LASER=1
	BLIP=6
	JUMP=5
	COIN=0
	EXPLOSION=2
	POWERUP=3
	def initialize(args)
		@objhandle = SoLoudImporter.Sfxr_create()
	end
	def destroy()
		SoLoudImporter.Sfxr_destroy(@objhandle)
	end
	def reset_params()
		SoLoudImporter.Sfxr_resetParams(@objhandle)
	end
	def load_params(aFilename)
		SoLoudImporter.Sfxr_loadParams(@objhandle, aFilename)
	end
	def load_preset(aPresetNo, aRandSeed)
		SoLoudImporter.Sfxr_loadPreset(@objhandle, aPresetNo, aRandSeed)
	end
	def set_looping(aLoop)
		SoLoudImporter.Sfxr_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Sfxr_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Sfxr_stop(@objhandle)
	end
end

class Speech
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.Speech_create()
	end
	def destroy()
		SoLoudImporter.Speech_destroy(@objhandle)
	end
	def set_text(aText)
		SoLoudImporter.Speech_setText(@objhandle, aText)
	end
	def set_looping(aLoop)
		SoLoudImporter.Speech_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Speech_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Speech_stop(@objhandle)
	end
end

class Wav
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.Wav_create()
	end
	def destroy()
		SoLoudImporter.Wav_destroy(@objhandle)
	end
	def load(aFilename)
		SoLoudImporter.Wav_load(@objhandle, aFilename)
	end
	def load_mem(aMem, aLength)
		SoLoudImporter.Wav_loadMem(@objhandle, aMem, aLength)
	end
	def get_length()
		SoLoudImporter.Wav_getLength(@objhandle)
	end
	def set_looping(aLoop)
		SoLoudImporter.Wav_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Wav_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Wav_stop(@objhandle)
	end
end

class WavStream
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(args)
		@objhandle = SoLoudImporter.WavStream_create()
	end
	def destroy()
		SoLoudImporter.WavStream_destroy(@objhandle)
	end
	def load(aFilename)
		SoLoudImporter.WavStream_load(@objhandle, aFilename)
	end
	def get_length()
		SoLoudImporter.WavStream_getLength(@objhandle)
	end
	def set_looping(aLoop)
		SoLoudImporter.WavStream_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.WavStream_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.WavStream_stop(@objhandle)
	end
end
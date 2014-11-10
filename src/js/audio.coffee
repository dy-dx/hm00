# Sorry about the mess!
# I copy-pasted this from an earlier project in a hurry.

AudioControls = require './audiocontrols'

# waveform - from 0 - 1 . no sound is 0.5. Array [binCount]
waveData = []
# levels of each frequency - from 0 - 1. No sound is 0. Array [levelsCount]
levelsData = []

volSens = 1.0
beatHoldTime = 18
beatDecayRate = 0.94
# minimum volume to trigger a beat
BEAT_MIN = 0.36

beatCutOff = 0
beatTime = 0

# Init audio context & analyser
audioContext = new (window.AudioContext || window.webkitAudioContext)()
analyser = audioContext.createAnalyser()
analyser.fftSize = 1024
analyser.smoothingTimeConstant = 0.8 # 0<->1. 0 is no time smoothing
analyser.connect(audioContext.destination)

binCount = analyser.frequencyBinCount # 512
levelsCount = 16  # should be factor of 512
levelBins = Math.floor(binCount / levelsCount) # number of bins in each level
freqByteData = new Uint8Array(binCount) # bars - bar data is from 0 - 256 in 512 bins. no sound is 0
timeByteData = new Uint8Array(binCount) # waveform - waveform data is from 0-256 for 512 bins. no sound is 128

class Audio
  constructor: ->
    @beatHit = false
    # averaged normalized level from 0 - 1
    @level = 0
    # we'll fix it later
    @context = audioContext

  onBeat: ->
    @beatHit = true

  currentTime: ->
    @controls.audio.currentTime

  # Called every frame
  updateAudio: ->
    return unless @isPlaying()

    @beatHit = false

    # GET DATA
    analyser.getByteFrequencyData(freqByteData) #<-- bar chart
    analyser.getByteTimeDomainData(timeByteData) # <-- waveform

    #normalize waveform data
    for i in [0...binCount]
      waveData[i] = ((timeByteData[i] - 128) /128 ) * volSens
    # TODO - cap levels at 1 and -1 ?

    # normalize levelsData from freqByteData
    for i in [0...levelsCount]
      sum = 0
      for j in [0...levelBins]
        sum += freqByteData[(i * levelBins) + j]

      levelsData[i] = sum / levelBins/256 * volSens # freqData maxs at 256

      # adjust for the fact that lower levels are percieved more quietly
      # make lower levels smaller
      # levelsData[i] *=  1 + (i/levelsCount)/2

    # Get average level
    # sum = _.reduce(levelsData, ((a, b) -> a + b), 0)
    sum = levelsData.reduce ((a, b) -> a + b), 0
    @level = sum / levelsCount

    # Beat Detection
    if (@level > beatCutOff && @level > BEAT_MIN)
      # console.log 'beat!', @level
      @onBeat()
      beatCutOff = @level * 1.4
      beatTime = 0
    else
      if (beatTime <= beatHoldTime)
        beatTime += 1
      else
        beatCutOff *= beatDecayRate
        beatCutOff = Math.max(beatCutOff, BEAT_MIN)

  isPlaying: ->
    audio = @controls.audio
    !audio.paused && !audio.ended && audio.currentTime > 0

  load: (url, callback) ->
    self = @
    @controls = new AudioControls(url)
    @source = @context.createMediaElementSource(@controls.audio)
    @source.connect(analyser)

  startSound: ->
    @controls.play()

audio = new Audio()
module.exports = audio

module.exports = class AudioControls
  constructor: (url) ->
    @audio = audio = document.createElement 'audio'
    audio.preload = 'auto'
    audio.autoplay = false
    audio.type = 'audio/mpeg'
    @setSrc url if url
    audio.controls = true
    audio.style.position = 'absolute'
    width = 500
    audio.style.width = width + 'px'
    audio.style.left = "calc(50% - #{width/2}px)"
    audio.style.bottom = '25px'
    audio.style.display = 'none'
    audio.style.opacity = 0.5
    audio.style.transition = 'opacity 1s'
    document.body.appendChild audio

    # @timeoutId = null

    # document.addEventListener 'mousemove', (evt) ->
    #   audio.style.opacity = 0.5
    #   clearTimeout @timeoutId if @timeoutId?

    #   @timeoutId = setTimeout ->
    #     audio.style.opacity = 0
    #   , 1000



  setSrc: (url) ->
    @audio.src = url
    @audio.load()

  play: ->
    throw Error 'No audio URL provided.' unless @audio.src

    @audio.style.display = ''
    @audio.volume = 1
    @audio.play()

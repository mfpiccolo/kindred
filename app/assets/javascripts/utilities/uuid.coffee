class App.UUID
  @generate = ->
    d = new Date().getTime()
    uuid = "xxxxxxxx-xxxx-4xxx-xxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
      r = (d + Math.random() * 16) % 16 | 0
      d = Math.floor(d / 16)
      ((if c is "x" then r else (r & 0x7 | 0x8))).toString 16
    )
    uuid

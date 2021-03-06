###
Submit form via AJAX
###
$.fn.ajaxify = ->
  return @ if 'function' != typeof FormData
  @.submit ->
    xhr = 0
    aborted = false
    $(@).prev('div').remove() # Удалить сообщения об ошибках
    modal = $ '.modal'
    .one 'shown.bs.modal', =>
      $ @
      .trigger 'db3d.file.dropped', [data = new FormData @]
      xhr = $.ajax
        type: @method
        url: @action
        data: data
        processData: false
        contentType: false
        xhr: ->
          z = $.ajaxSettings.xhr()
          z.upload.onprogress = (e)->
            progress.css width: "#{e.loaded / e.total * 100}%"
          z
      .always ->
        xhr = 0
        modal.modal 'hide'
        do reset
      .done (data)->
        location.href = data.path
      .fail (xhr)=>
        return if aborted
        $(@).before $ errorMsg xhr
    .one 'hide.bs.modal', ->
      return unless xhr
      aborted = true
      xhr.abort()
      xhr = 0
    .modal()
    progress = $ '.progress-bar', modal
    do reset = ->
      progress.css
        width: 0
        transition: 'none'
    false
  @

# Получить текст сообщений об ощибке
errorMsg = (xhr)->
  if ///^\s*<div\s[\s\S]+</div>\s*$///i.test xhr.responseText
    xhr.responseText
  else
    tError xhr.statusText

tError = withOut ->
  div
    class: 'alert alert-danger'
    @

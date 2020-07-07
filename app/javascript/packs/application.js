// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "controllers"

$(document).on('turbolinks:load', function() {
  $('.star-input').click(function() {
    $(this).parent()[0].reset();
    let prevStars = $(this).prevAll();
    let nextStars = $(this).nextAll();
    prevStars.attr('checked',true);
    nextStars.attr('checked',false);
    $(this).attr('checked',true);
    $(document.getElementById("star-value")).val($(this).attr('id'))
  });

  $('.star-input-label').on('mouseover',function() {
    let prevStars = $(this).prevAll();
    prevStars.addClass('hovered');
  });

  $('.star-input-label').on('mouseout',function(){
    let prevStars = $(this).prevAll();
    prevStars.removeClass('hovered');
  })

  $('#link-rate').on('click', function(event) {
    let rating = parseInt($('#link-rate').data('rating')) // Extract info from data-* attributes
    console.log('rating:', rating)

    let currentStar = rating === 0 ? document.getElementById('1') : document.getElementById(`${rating}`)
    $(currentStar).parent()[0].reset();
    let prevStars = $(currentStar).prevAll();
    let nextStars = $(currentStar).nextAll();
    prevStars.attr('checked',true);
    nextStars.attr('checked',false);
    $(currentStar).attr('checked', rating === 0 ? false : true);

    $(document.getElementById("star-value")).val(rating.toString())
  });

  $('#rating-widget').on('submit', function(event) {
    event.preventDefault();
    setTimeout(function() {$('#rateModal').modal('dispose')}, 500);
    console.log("Hi")
  });

});
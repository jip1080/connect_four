$(document).ready(function() {
 var player_count = 0;
 var player_options = [];

 fetch_player_list = function() {
   $.ajax
  ({
    url: '/players',
    type: 'get',
    dataType: 'json',
    success: function(data) {
      data.forEach(function(player, index) {
        option = "<option value='" + player.id + "'>" + player.name + "</option>";
        player_options.push(option);
      });
    }
  });
 };


 $('.add-player').click(function(e) {
   player_count = player_count + 1;
   var v = "<div class='player'>" +
   "<label>Player" + player_count + "</label>" +
   "<select name='player" + player_count + "' id='player" + player_count + "'>"
   player_options.forEach(function(player) {
     v = v + player;
   });
   v = v + "<option value='abc'>abc</option>" +
   "</select>" +
   "</div>";
   $('.players').append(v);
   $('#player_count').val(player_count);
   if(player_count >= 2) {
     $('#submit').prop('disabled', false);
     $('.add-player').hide();
   }
 });

 fetch_player_list();

 validateFormInput = function(field_name) {
   var obj = document.forms['new_game'][field_name].value;
   if (isNaN(obj) || (obj < 4) || (obj > 8)) {
    alert(name + " must be a number greater than 3, less than 9" );
    return false;
   }
   return true;
 };

 validateForm = function() {
   var status = validateFormInput('rows');
   if(status === true) {
     status = validateFormInput('columns');
     }
   return status;
 }
})

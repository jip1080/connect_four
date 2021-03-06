$(document).ready(function() {
  $('.ai-thinking').hide();

  selectColor = function(player_number) {
    switch(player_number) {
      case 1:
        color = 'red';
        break;
      case 2:
        color = 'black';
        break;
      case 3:
        color = 'blue';
        break;
      default:
        color = 'white';
    };
    return color;
  };

  colorizeToken = function(col, row, player_number) {
    token_id = '#token_' + col + '_' + row;
    console.log(token_id);
    $(token_id).removeClass('red white black blue');
    $(token_id).addClass(selectColor(player_number));
  };

  updateTurnName = function(turn_name) {
    $('#player_turn')[0].innerText = turn_name;
  };

  setWinCondition = function() {
    $('.column-select').prop('disabled', true);
    $('.column-select').removeClass('enabled');
    $('#winner_name')[0].innerText = $('#player_turn')[0].innerText;
    $('#winner').prop('disabled', false);
    $('#status')[0].innerText = 'Completed';
  };
  
  setDrawCondition = function() {
    $('.column-select').prop('disabled', true);
    $('.column-select').removeClass('enabled');
    $('#winner_name')[0].innerText = 'Draw';
    $('#winner').prop('disabled', false);
    $('#status')[0].innerText = 'Completed';
  };


  callForComputerMove = function() {
    $('.board').hide();
    $('.ai-thinking').show();
    var game_id = $('#game_id')[0].innerText;
    $.ajax
      ({
        url: game_id + '/computer_move',
        type: 'get',
        dataType: 'json',
        success: function(result) {
          $('.ai-thinking').hide(function() {
            $('.board').show(function() {
              colorizeToken(result.column, result.row, result.player_number);
            });
          });
          if(result.win_condition === true) {
            $('.ai-thinking').hide();
            $('.board').show();
            setWinCondition();
          } else if (result.draw_condition === true) {
            setDrawCondition();
          } else {
            updateTurnName(result.player_turn);
            if(result.computer_move === true) {
              callForComputerMove();
            };
          }
        }
      });
  };

  $('.column-select').click(function(e) {
    var game_id = $('#game_id')[0].innerText;
    $.ajax
    ({
      url: game_id + '/update_board',
      data: {'col': this.id},
      type: 'post',
      success: function(result) {
        colorizeToken(result.column, result.row, result.player_number);
        if(result.win_condition === true) {
          setWinCondition();
        } else if (result.draw_condition === true) {
          setDrawCondition();
        } else {
          updateTurnName(result.player_turn);
          if(result.computer_move === true) {
            callForComputerMove();
          }
        }
      }
    });
  });

  if ($('.ai-first').length > 0) {
    callForComputerMove();
  };
})

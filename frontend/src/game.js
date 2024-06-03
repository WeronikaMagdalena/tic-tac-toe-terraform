const tiles = document.querySelectorAll(".tile");
const gameOverArea = document.getElementById("game-over-area");
const gameOverText = document.getElementById("game-over-text");
const playAgain = document.getElementById("play-again");
const playerLeftElement = document.getElementById('player-left');
const playerRightElement = document.getElementById('player-right');

setInterval(fetchGameState, 100);

tiles.forEach((tile) => tile.addEventListener("click", function () {
  const tileNumber = tile.dataset.index;
  console.log('Tile clicked: ' + tileNumber);
  fetch('http://localhost:8080/game/play?tileNumber=' + tileNumber, {
    method: 'POST'
  })
    .then(response => response.json())
    .then(data => {
      console.log(data);
      updateBoard(data.board);
      if (data.gameOver == true) {
        gameOverArea.className = "visible";
        let text = "Draw!";
        if (data.winner) {
          text = `Winner is ${data.winner}!`;
        }
        gameOverText.innerText = text;
      }
    })
    .catch(error => console.error('Error:', error));
}));

function updateBoard(boardState) {
  tiles.forEach((tile, index) => {
    tile.innerText = boardState[index];
  });
}

function fetchGameState() {
  fetch('http://localhost:8080/game/state')
    .then(response => response.json())
    .then(data => {
      updateBoard(data.board);
      document.getElementById('player-left').innerText = data.player1;
      document.getElementById('player-right').innerText = data.player2;
    })
    .catch(error => console.error('Error fetching game state:', error));
}

playAgain.addEventListener("click", function () {
  fetch('http://localhost:8080/game/start', {
    method: 'POST'
  })
  console.log("New game started!");
  gameOverArea.className = "hidden";
  clearBoard();
});

function clearBoard() {
  tiles.forEach((tile) => (tile.innerText = ""));
}

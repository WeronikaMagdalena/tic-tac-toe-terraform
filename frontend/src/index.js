document.getElementById("playerForm").addEventListener("submit", function (event) {

  const playerName = document.getElementById("playerName").value;

  fetch("http://localhost:8080/game/playername?playerName=" + playerName, {
    method: "POST",
    body: JSON.stringify({ name: playerName })
  })
    .then(response => {
      if (response.ok) {
        console.log("New player: " + playerName);
      }
    })

});
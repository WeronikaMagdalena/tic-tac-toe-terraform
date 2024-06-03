package com.tictactoe.model;

import lombok.Data;

@Data
public class Game {
    Character[] board;
    Character winner;
    Boolean gameOver = false;
    String player1;
    String player2;

    public Game() {
        board = new Character[9];
    }

    public void newGame() {
        board = new Character[9];
        winner = null;
        gameOver = false;
    }

}

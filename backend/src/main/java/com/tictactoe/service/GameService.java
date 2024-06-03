package com.tictactoe.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.tictactoe.model.Game;

@Slf4j
@Service
public class GameService {
    Game game = new Game();
    private static final Character PLAYER_X = 'X';
    private static final Character PLAYER_O = 'O';
    Character turn = PLAYER_X;
    private static final Integer[][] WINNING_COMBINATIONS = {
            // Rows
            {0, 1, 2},
            {3, 4, 5},
            {6, 7, 8},
            // Columns
            {0, 3, 6},
            {1, 4, 7},
            {2, 5, 8},
            // Diagonals
            {0, 4, 8},
            {2, 4, 6}
    };

    public void start() {
        game.newGame();
    }

    public void saveName(String playerName) {
        if (game.getPlayer1() == null) {
            game.setPlayer1(playerName);
        } else if (game.getPlayer2() == null) {
            game.setPlayer2(playerName);
        }
    }

    public Game getGame() {
        return game;
    }

    public Game makeMove(Integer tileNumber) {
        if (game.getGameOver())
            return game;
        Character[] board = game.getBoard();
        if (board[tileNumber] == null) {
            if (turn == PLAYER_X) {
                board[tileNumber] = PLAYER_X;
                turn = PLAYER_O;
            } else {
                board[tileNumber] = PLAYER_O;
                turn = PLAYER_X;
            }
        }
        checkWinner();
        isTie();
        return game;
    }

    public void checkWinner() {
        Character[] board = game.getBoard();
        for (Integer[] combination : WINNING_COMBINATIONS) {
            if (board[combination[0]] != null &&
                    board[combination[0]] == board[combination[1]] &&
                    board[combination[0]] == board[combination[2]]) {
                Character winner = board[combination[0]];
                log.info("Player {} wins!", winner);
                game.setWinner(winner);
                game.setGameOver(true);
                return;
            }
        }
    }

    public Boolean isTie() {
        Character[] board = game.getBoard();
        for (Character tile : board) {
            if (tile == null) {
                return false;
            }
        }
        game.setGameOver(true);
        return true;
    }

}

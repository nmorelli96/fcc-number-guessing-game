#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

WELCOME() {
  GUESS_TRIES=0
  echo -e "\nEnter your username:\n"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  NAME_LENGTH=${#USERNAME}

  if (( $NAME_LENGTH > 22 ))
  then
    echo Please, enter a username shorter than 22 characters
    WELCOME
  else
    if [[ -z $USER_ID ]]
    then
      INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
      echo Welcome, $USERNAME! It looks like this is your first time here.
      echo Guess the secret number between 1 and 1000:
      SECRET_NUMBER=$(( RANDOM % 999 + 1 )) 
      UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME'")
      GUESS
    else
      USER_DATA=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
      echo "$USER_DATA" | while read USER_ID BAR USER BAR GAMES_PLAYED BAR BEST_GAME
        do
          echo -e "\nWelcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
        done
      echo -e "\nGuess the secret number between 1 and 1000:"
      SECRET_NUMBER=$(( RANDOM % 999 + 1 )) 
      UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME'")
      GUESS
    fi
  fi
}

GUESS() {
  read CHOICE
  if [[ ! $CHOICE =~ ^[0-9]+$ ]] 
  then
    echo That is not an integer, guess again:
    GUESS
  else
    if (( CHOICE < SECRET_NUMBER ))
    then
      (( GUESS_TRIES++ ))
      echo It\'s higher than that, guess again: 
        GUESS
    elif (( CHOICE > SECRET_NUMBER ))
    then
      (( GUESS_TRIES++ ))
      echo It\'s lower than that, guess again: 
        GUESS
    elif (( CHOICE = SECRET_NUMBER ))
    then
      (( GUESS_TRIES++ ))
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
      if (( GUESS_TRIES < BEST_GAME || BEST_GAME == 0 ))
      then
        UPDATE_USER_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_TRIES WHERE username='$USERNAME'")
        echo You guessed it in $GUESS_TRIES tries. The secret number was $SECRET_NUMBER. Nice job\!
      else
        echo You guessed it in $GUESS_TRIES tries. The secret number was $SECRET_NUMBER. Nice job\!
      fi
    fi
  fi
}

WELCOME
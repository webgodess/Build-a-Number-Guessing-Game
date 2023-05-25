#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo $SECRET_NUMBER
NUMBER_GUESSES=0

echo "Enter your username:"
read -r USERNAME

USERNAME_IN_DB=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -n $USERNAME_IN_DB ]]; then
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = (SELECT user_id FROM users WHERE username = '$USERNAME')")
  BEST_GAME=$($PSQL "SELECT COALESCE(MIN(number_guesses), 0) FROM games WHERE user_id = (SELECT user_id FROM users WHERE username = '$USERNAME')")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  QUERY_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

echo "Guess the secret number between 1 and 1000:"

while true; do
  read -r GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_GUESSES=$((NUMBER_GUESSES + 1))

  if ((GUESS < SECRET_NUMBER)); then
    echo "It's higher than that, guess again:"
  elif ((GUESS > SECRET_NUMBER)); then
    echo "It's lower than that, guess again:"
  else
    QUERY_RESULT=$($PSQL "INSERT INTO games (user_id, number_guesses) VALUES ($USER_ID, $NUMBER_GUESSES)")
    echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!" 
    break
  fi
done

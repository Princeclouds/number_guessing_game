#!/bin/bash

# Connect to PostgreSQL database or create it if it doesn't exist
PSQL="psql --username=freecodecamp --dbname=number_guessing -t --no-align -c"

# Random number generation
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt user for username
echo "Enter your username:"
read USERNAME

# Check if user exists in the database
USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]; then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into database
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1001)")
  GAMES_PLAYED=0
  BEST_GAME=1001
else
  # Returning user
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

 # Game logic
echo "Guess the secret number between 1 and 1000:"
GUESSES=0
while true; do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESSES=$((GUESSES + 1))

  if (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    
    NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
    if (( GUESSES < BEST_GAME )); then
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$GUESSES WHERE username='$USERNAME'")
    else
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'")
    fi
    break
  fi
done

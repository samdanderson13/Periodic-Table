#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# A program for querying the periodic_table database

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
  exit
elif [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT_ROW=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1;")
  if [[ -z $ELEMENT_ROW ]]
  then
    echo "I could not find that element in the database."
    exit
  else
    IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< $ELEMENT_ROW
  fi
else
  # input is a string
  # check if it's a symbol
  if [[ ! $1 =~ ...+ ]]
  then
    CHECK_SYMBOL=$($PSQL "SELECT * FROM elements WHERE symbol='$1';")
    if [[ $CHECK_SYMBOL ]]
    then
      IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< $CHECK_SYMBOL
    fi
  fi
  # check if it's a name
  if [[ -z $CHECK_SYMBOL ]] 
  then
    CHECK_NAME=$($PSQL "SELECT * FROM elements WHERE name='$1';")
    if [[ $CHECK_NAME ]]
    then
      IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< $CHECK_NAME
    else
      echo I could not find that element in the database.
      exit
    fi
  fi
fi

# $ATOMIC_NUMBER, $SYMBOL, and $NAME have already been set
# query properties table and set $MASS, $MELTING, $BOILING, and $TYPE_ID
PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER;")
IFS="|" read MASS MELTING BOILING TYPE_ID <<< $PROPERTIES
# query types table and get type name
TYPE_NAME=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID;")
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_NAME, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
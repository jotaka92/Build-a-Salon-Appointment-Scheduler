#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
  do
    echo "$SERVICE_ID) $NAME"
  done 
  read SERVICE_ID_SELECTED   

  #if selection different than available services
  SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #ask phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    #if not register ask for name
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
    
      #insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #time of the appoinment
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_SELECTED'")
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ //g'), $(echo $CUSTOMER_NAME | sed 's/ //g')?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
    VALUES ('$CUSTOMER_ID', $SERVICE_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ //g') at $(echo $SERVICE_TIME | sed 's/ //g'), $(echo $CUSTOMER_NAME | sed 's/ //g')."
  fi 

}

MAIN_MENU

#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
# Welcome
echo "~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICE_ID_SELECTED=""
SERVICE_NAME_SELECTED=""

VALIDATE_SERVICE() {
  LEAD_MSG=$1
  echo -e "\n$LEAD_MSG"
  SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  echo -e "\nPlease select a service"
  # Get service Id from user
  read SERVICE_ID_SELECTED
  # Validate selection
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    # Empty string => Invalid selection, send user back to start of method
    VALIDATE_SERVICE "I could not find that service. What would you like today?"
  fi
}

VALIDATE_SERVICE "The following are the services we offer"

# Get customer phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
# Validate customer phone number
if [[ -z $CUSTOMER_NAME ]]
then
  echo "We don't have your details on record - can you please give your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
fi
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ //')
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
SERVICE_NAME_SELECTED=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ +//')

echo -e "\nWhat time would you like your $SERVICE_NAME_SELECTED, $CUSTOMER_NAME?" 
read SERVICE_TIME
    
APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
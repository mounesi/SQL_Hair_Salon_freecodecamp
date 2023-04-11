#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU(){
  echo "Welcome to My Salon, how can I help you?"

  services_query="SELECT service_id, name FROM services ORDER BY service_id;"
  AVAILABLE_SERVICES=$($PSQL "$services_query")

  echo -e "$AVAILABLE_SERVICES" | while read -r line
  do
    service_id=$(echo $line | cut -f 1 -d '|')
    service_name=$(echo $line | cut -f 2 -d '|')
    service_name=$(echo $service_name | xargs) # remove leading/trailing whitespace
    echo "$service_id) $service_name" | sed "s/ //"
  done



  read SERVICE_ID_SELECTED
  echo "$SERVICE_ID_SELECTED"

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #echo "$SERVICE_NAME" | sed "s/ //"
  if [[ -z $SERVICE_NAME ]]
  then
    # send to main menu
    MAIN_MENU 
  fi
}

PROMPT_MENU(){

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #CUSTOMER_ID=$(echo "$CUSTOMER_ID" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  echo "HERE IS THE CUSTOMER ID"
  echo "$CUSTOMER_ID"

  if [[ -z $CUSTOMER_ID ]]
  then 
    # add other customer's info
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    CUSTOMER_ID_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE') RETURNING customer_id")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$(echo "$CUSTOMER_ID" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') # remove leading/trailing whitespace
    #echo "$CUSTOMER_ID"    
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME


  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  SERVICE_NAME=$(echo "$SERVICE_NAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//') # remove leading/trailing whitespace
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
PROMPT_MENU

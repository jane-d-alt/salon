#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_NAME != "name" && $SERVICE_ID =~ ^[0-9]+$ ]]
    then
        echo -e "$SERVICE_ID) $SERVICE_NAME"
    fi
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] #not a number
  then
    MAIN_MENU "Please enter a number to select a service."
  else 
    #get service
    SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SELECTED_SERVICE ]] #if service doesn't exist
    then
      #tell user number not in list, show main menu
      MAIN_MENU "Please enter a number from the list of services to select a service."
    else
      #proceed
      echo -e "\nYou have selected $SELECTED_SERVICE! Please enter your phone number:\n"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nIt looks like you're a new customer.\nWelcome!\nPlease give us a name for your booking:"
        read CUSTOMER_NAME
        NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo $CUSTOMER_ID
        BOOK_SERVICE "Welcome, $CUSTOMER_NAME!"
      else
        CUSTOMER_NAME = $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        BOOK_SERVICE "Welcome back, $CUSTOMER_NAME!"
      fi
    fi
  fi
}

BOOK_SERVICE(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  echo -e "What time would you like to get your $SELECTED_SERVICE?\nPlease enter a time in format HH:MM (24-hour format):"
  read SERVICE_TIME
  #add to appointments
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "I have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU "\nWelcome to the salon! Please select a service:\n"



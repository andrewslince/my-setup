#!/bin/bash

echo "Enter new user:"
read NEW_USER

# adding new user
adduser $NEW_USER

exit 0

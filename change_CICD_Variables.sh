#!/bin/bash

#ADD your credentials and URLs
USERNAME="<Your_Username>"
PASSWORD="<Your_Password>"
LOGIN_URL= "<Your_login_Access_URL>"
GITLAB_API_URL= "<Your_Project_API>"
PROJECT_ID= "<Your_Project_ID>"
ACCESS_TOKEN= "<Your_Project_Access_Token>"
Gitlab_url="<Your_Project_URL>"
gitlab_pass="<Your_Gitlab_Password>"


# Iterate through the passed key-value pairs and update CI/CD variables (from the first script)
for update in "${@}"; do
    IFS='=' read -r key value <<< "${update}"
    echo key= ${key} value = ${value}
    # Update CI/CD variable
    VARIABLE_KEY="${key}" 
    NEW_VARIABLE_VALUE="${value}"
    # Update CI/CD variable
    UPDATE_VARIABLE=$(curl --request PUT \
	  --url "${GITLAB_API_URL}/projects/${PROJECT_ID}/variables/${VARIABLE_KEY}" \
	  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
	  --cookie cookies.txt \
	  --data-urlencode "value=${NEW_VARIABLE_VALUE}")

	# Check for errors in the response
	if [[ $(echo "${UPDATE_VARIABLE}" | jq '.error') == "null" ]]; then
	  echo "CI/CD Variable 'BUDGET' updated successfully."
	else
 	 echo "Error updating CI/CD Variable 'BUDGET':"
 	 echo "${UPDATE_VARIABLE}" | jq .
 	 exit 1
	fi
done

# Get the login page to extract any necessary tokens or cookies
login_page=$(curl -s "${LOGIN_URL}")

# Extract any necessary tokens or cookies (replace with actual extraction)
# For example, extracting CSRF token from HTML: 
#csrf_token=$(echo "${login_page}" | grep -oP 'csrf_token=\K[^&]+')


# Perform login
response=$(curl -s -c cookies.txt -b cookies.txt -d "username=${USERNAME}&password=${PASSWORD}&csrf_token=${csrf_token}" -X POST "${LOGIN_URL}")

# Do something after logging in (replace with your own logic)
echo "Logged in successfully!"

# Fetch CI/CD variables after login
CI_CD_VARIABLES=$(curl --request GET \
  --url "${GITLAB_API_URL}/projects/${PROJECT_ID}/variables" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --cookie cookies.txt)

# Check for errors in the response
if [[ $(echo "${CI_CD_VARIABLES}" | jq '. | if type == "array" then length else 1 end') -eq 0 ]]; then
  echo "Error: Unable to fetch CI/CD variables. Check your credentials or project ID."
  exit 1
fi


# Process and display CI/CD variables
echo "CI/CD Variables:"
if [[ $(echo "${CI_CD_VARIABLES}" | jq 'type') == "array" ]]; then
  echo "${CI_CD_VARIABLES}" | jq -c '.[] | {key: .key, value: .value}' | while IFS= read -r line; do
    echo "${line}" | jq -r '"\(.key): \(.value)"'
  done
else
  #echo "Error in CI/CD Variables response:"
  echo "${CI_CD_VARIABLES}" | jq .
fi

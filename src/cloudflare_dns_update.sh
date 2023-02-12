#!/bin/bash
#
# @brief    Script to update the IP address of a domain managed with Cloudflare.
#
# @details  Code inspired by: https://gist.github.com/Tras2/cba88201b17d765ec065ccbedfb16d9a
#
# @author   Luis C. Garcia-Peraza Herrera (luiscarlos.gph@gmail.com).
# @date     11 Feb 2023.

# E-mail associated with your Cloudflare account
EMAIL="<email_here>"

# Domain name you want to edit
ZONE_NAME="<domain_here>"
DNS_RECORD="<subdomain_here>"
DOMAIN_NAME="${DNS_RECORD}.${ZONE_NAME}"

# API token with powers to edit the DNS configuration of the domain
API_TOKEN="<api_token_here>"

# Check that jq is installed
CHECK_JQ=$(which jq)
if [ -z "${CHECK_JQ}" ]; then
    echo -e "\033[0;31m [ERROR] jq is not installed. To install it run: 'sudo apt install jq'."
    exit 1
fi

# Check that that the domain name exists
CHECK_DOMAIN_EXISTS=$(dig -t a +short ${DOMAIN_NAME} | tail -n1)
if [ -z "${CHECK_DOMAIN_EXISTS}" ]; then
    echo -e "\033[0;31m [ERROR] cannot retrieve the current IP address for the provided domain name. Are you sure that ${DOMAIN_NAME} exists?"
    exit 1
fi

# Check that the API token is working
USER_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" -H "Authorization: Bearer ${API_TOKEN}" -H "Content-Type:application/json" | jq -r '{"result"}[] | .id')
if [ ${USER_ID} = "null" ]; then
    echo -e "\033[0;31m [ERROR] the API token is wrong."
    exit 1
fi

# Retrive your current IP address
CURRENT_IP=$(curl -s -X GET -4 https://ifconfig.co)
echo -e "\033[0;37m [INFO] External IP address: ${CURRENT_IP}"

# Get the IP stored in Cloudflare
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME&status=active" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" | jq -r '{"result"}[] | .[0] | .id')
echo -e "\033[0;37m [INFO] Cloudflare zone id: ${ZONE_ID}"
DNS_RECORD_A_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=${DOMAIN_NAME}" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN")
DNS_RECORD_A_IP=$(echo $DNS_RECORD_A_ID |  jq -r '{"result"}[] | .[0] | .content')
echo -e "\033[0;37m [INFO] DNS record id: ${DNS_RECORD_A_IP}"

# Update the record if it needs to be updated 
if [ $DNS_RECORD_A_IP != $CURRENT_IP ]; then
    echo -e "\033[0;37m [INFO] The record needs to be updated."
    RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$(echo $DNS_RECORD_A_ID | jq -r '{"result"}[] | .[0] | .id')" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" --data "{\"type\":\"A\",\"name\":\"$DNS_RECORD\",\"content\":\"$CURRENT_IP\",\"ttl\":1,\"proxied\":true}" | jq -r '.errors')
    if [ "${RESPONSE}" = "[]" ]; then
        echo -e "\033[0;37m [INFO] The DNS record for ${DOMAIN_NAME} has been successfully updated."
    else
        echo -e "\033[0;31m [ERROR] The DNS record update for ${DOMAIN_NAME} failed."
    fi
else
    echo -e "\033[0;37m [INFO] The record does not need to be updated."
fi

#!/bin/bash
#
# @brief    Script to update the IP address of a domain managed with Cloudflare.
#
# @details  Code inspired by: https://gist.github.com/Tras2/cba88201b17d765ec065ccbedfb16d9a
#
# @author   Luis C. Garcia-Peraza Herrera (luiscarlos.gph@gmail.com).
# @date     11 Feb 2023.

# E-mail associated with your Cloudflare account
EMAIL=<your_email>

# Domain name you want to edit
ZONE_NAME=<your_domain>
DNS_RECORD=<your_subdomain>
DOMAIN_NAME="$DNS_RECORD.$ZONE_NAME"

# API token with powers to edit the DNS configuration of the domain
API_TOKEN=<your_api_token>

# Check that jq is installed
CHECK_JQ=$(which jq)
if [ -z "${CHECK_JQ}" ]; then
    echo -e "\033[0;31m [-] jq is not installed. To install it run: 'sudo apt install jq'."
    exit 1
fi

# Check that that the domain name exists
CHECK_DOMAIN_EXISTS=$(dig -t a +short ${DOMAIN_NAME} | tail -n1)
if [ -z "${CHECK_DOMAIN_EXISTS}" ]; then
    echo -e "\033[0;31m [-] cannot retrieve the current IP address for the provided domain name. Are you sure that ${DOMAIN_NAME} exists?"
    exit 1
fi

# Check that the API token is working
USER_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" -H "Authorization: Bearer ${API_TOKEN}" -H "Content-Type:application/json" | jq -r '{"result"}[] | .id')
# TODO: check what happens here when the token is wrong, what is the value of USER_ID?

# Retrive your current IP address
CURRENT_IP=$(curl -s -X GET -4 https://ifconfig.co)






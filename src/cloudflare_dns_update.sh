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
check_jq=$(which jq)
if [ -z "${check_jq}" ]; then
    echo -e "\033[0;31m [-] jq is not installed. To install it run: 'sudo apt install jq'."
    exit 1
fi

# Check that that the domain name exists
check_record_ipv4=$(dig -t a +short ${DOMAIN_NAME} | tail -n1)

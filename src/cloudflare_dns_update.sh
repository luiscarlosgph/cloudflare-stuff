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

# API token with powers to edit the DNS configuration of the domain
API_TOKEN=<your_api_token>




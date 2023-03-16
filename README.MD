# Ding Dong Doorbell

## Overview

This is a basic server that will respond to call:

GET /press on port 8080

The repsonse will be 
"Ding Dong"

## Provenance



## SBOM

To generate a list of all dependencies please use this command

go list -f '{{ join .Deps "\n" }}'

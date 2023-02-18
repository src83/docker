#!/bin/bash

# Logfiles are not created at the same time.
# So we need tiny delay before run 'chmod'.
sleep 2s;

# Permissions and Ownership correction
chmod 666 /var/log/mysql/*
chown 1000.1000 /var/log/mysql/*

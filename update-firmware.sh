#!/bin/bash

fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update -y

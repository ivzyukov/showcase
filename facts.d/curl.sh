#!/bin/bash
echo `curl http://169.254.169.254/meta-data/meta-data/public-hostname 2>/dev/null`


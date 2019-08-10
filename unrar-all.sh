#!/bin/bash
find . -name "*.rar" -exec unrar * -o+ {} \;

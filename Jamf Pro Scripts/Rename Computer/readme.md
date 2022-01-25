# renameComputer.zsh

Inspired by Matthew Warren's (aka Haircut) Python-based workflow for this process.
Here's his blog post about it: https://www.macblog.org/posts/automatically-renaming-computers-from-a-google-sheet-with-jamf-pro/

Here's his Python-based approach: https://gist.github.com/haircut/1debf91078ce75612bf2f0c3b3d99f03

You need to use the following format for Google Sheets: `https://docs.google.com/spreadsheets/u/0/d/<documentID>/export?format=csv&id=<documentID>&gid=0`

---

## IMPORTANT - REQUIRED PARAMETERS
Pass the URL for your CSV in Parameter 4 in your JPS policy.
Set Parameter 5 in your JPS policy to `0` if not all computers require a defined hostname. Set to `1` if all computers require a defined hostname.

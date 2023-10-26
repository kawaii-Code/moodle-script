# Extract login token and get initial cookies
$LOGIN_TOKEN = lua ./extract_login_token.lua $(
    curl --cookie-jar cookies -s https://edu.mmcs.sfedu.ru/login/index.php |
    sls "logintoken"
)

# Log in with correct information
curl --cookie-jar cookies -b cookies -s `
    -d "anchor="                        `
    -d "logintoken=$LOGIN_TOKEN"        `
    -d "username=$(cat username.txt)"   `
    -d "password=$(cat password.txt)"   `
    -L https://edu.mmcs.sfedu.ru/login/index.php > $null

# Get the page :)
$ID = 11373 ;
$SESSKEY = lua extract_sesskey.lua $(
    curl -s -b cookies "https://edu.mmcs.sfedu.ru/mod/assign/view.php?id=$ID" |
    sls "sesskey=" |
    select -first 1
)

$ITEM_ID = lua extract_itemid.lua $(
    curl -s -b cookies "https://edu.mmcs.sfedu.ru/mod/assign/view.php?id=$ID&action=editsubmission" |
    sls "itemid="
)

$FILE = $args[0]

# Upload a file ??!
curl -b cookies `
    -F "repo_upload_file=@$FILE" `
    -F "repo_id=3" `
    -F "env=filemanager" `
    -F "savepath=/" `
    -F "author=Трухлов Иван" `
    -F "itemid=$ITEM_ID" `
    -F "sesskey=$SESSKEY" `
    https://edu.mmcs.sfedu.ru/repository/repository_ajax.php?action=upload

# Save that bad boy
curl -b cookies `
    -d "action=savesubmission" `
    -d "id=$ID" `
    -d "userid=33045" `
    -d "sesskey=$SESSKEY" `
    -d "_qf__mod_assign_submission_form=1" `
    -d "files_filemanager=$ITEM_ID" `
    -d "mform_isexpanded_id_submissionheader=1" `
    -L https://edu.mmcs.sfedu.ru/mod/assign/view.php

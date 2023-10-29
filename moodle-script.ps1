echo "Extracting login token and getting initial $COOKIES..."

$COOKIES = "$PSScriptRoot/cookies"

$LOGIN_TOKEN = lua "$PSScriptRoot/extract_login_token.lua" $( `
    curl --cookie-jar $COOKIES -s https://edu.mmcs.sfedu.ru/login/index.php | `
    sls "logintoken" `
)

echo "Logging in..."

curl --cookie-jar $COOKIES -b $COOKIES -s `
    -d "anchor="                        `
    -d "logintoken=$LOGIN_TOKEN"        `
    -d "username=$(cat "$PSScriptRoot/username.txt")"   `
    -d "password=$(cat "$PSScriptRoot/password.txt")"   `
    -L https://edu.mmcs.sfedu.ru/login/index.php > $null

$ID = $args[0]
echo "Id is $ID. Extracting stuff..."

$SESSKEY = lua "$PSScriptRoot/extract_sesskey.lua" $(
    curl -s -b $COOKIES "https://edu.mmcs.sfedu.ru/mod/assign/view.php?id=$ID" |
    sls "sesskey=" |
    select -first 1
)

$ITEM_ID = lua "$PSScriptRoot/extract_itemid.lua" $(
    curl -s -b $COOKIES "https://edu.mmcs.sfedu.ru/mod/assign/view.php?id=$ID&action=editsubmission" |
    sls "itemid="
)

for ($i = 1; $i -lt $args.Length; $i++) {
    $FILE = $args[$i]

    echo "Uploading '$FILE'"
    curl -s -b $COOKIES `
        -F "repo_upload_file=@$FILE" `
        -F "repo_id=3" `
        -F "env=filemanager" `
        -F "savepath=/" `
        -F "author=Трухлов Иван" `
        -F "itemid=$ITEM_ID" `
        -F "sesskey=$SESSKEY" `
        https://edu.mmcs.sfedu.ru/repository/repository_ajax.php?action=upload > $null
}

echo "Saving..."
curl -s -b $COOKIES `
    -d "action=savesubmission" `
    -d "id=$ID" `
    -d "userid=33045" `
    -d "sesskey=$SESSKEY" `
    -d "_qf__mod_assign_submission_form=1" `
    -d "files_filemanager=$ITEM_ID" `
    -d "mform_isexpanded_id_submissionheader=1" `
    -L https://edu.mmcs.sfedu.ru/mod/assign/view.php > $null

echo "Success!"

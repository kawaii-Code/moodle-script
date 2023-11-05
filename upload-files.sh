SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

COOKIES_PATH="$SCRIPT_DIR/cookies"

LOGIN_TOKEN=$( lua "$SCRIPT_DIR/extract_login_token.lua" "$(
    curl --cookie-jar $COOKIES_PATH -s https://edu.mmcs.sfedu.ru/login/index.php |
    grep "logintoken" |
    head -n1
)" )

echo "Вход в аккаунт..."

curl --cookie-jar $COOKIES_PATH -b $COOKIES_PATH -s   \
    -d "anchor="                                      \
    -d "logintoken=$LOGIN_TOKEN"                      \
    -d "username=$(cat "$SCRIPT_DIR/username.txt")"   \
    -d "password=$(cat "$SCRIPT_DIR/password.txt")"   \
    -L https://edu.mmcs.sfedu.ru/login/index.php > /dev/null

ID=$1

SESSKEY=$(lua "$SCRIPT_DIR/extract_sesskey.lua" "$(
    curl -s -b $COOKIES_PATH "https://edu.mmcs.sfedu.ru/mod/assign/view.php?id=$ID" -L |
    grep 'sesskey' |
    head -n1
)" )

ITEM_ID=$( lua extract_itemid.lua "$(
    curl -s -b $COOKIES_PATH "https://edu.mmcs.sfedu.ru/mod/assign/view.php?id=$ID&action=editsubmission" |
    grep "itemid" |
    head -n1
)" )

for FILE in "${@:2}"; do
    echo "Выкладывается '$FILE'"
    curl -b $COOKIES_PATH                       \
        -F "repo_upload_file=@$FILE"            \
        -F "repo_id=3"                          \
        -F "env=filemanager"                    \
        -F "savepath=/"                         \
        -F "author=$(cat $SCRIPT_DIR/name.txt)" \
        -F "itemid=$ITEM_ID"                    \
        -F "sesskey=$SESSKEY"                   \
        https://edu.mmcs.sfedu.ru/repository/repository_ajax.php?action=upload > /dev/null
done

echo "Сохранение ответа..."
curl -s -b $COOKIES_PATH                        \
    -d "action=savesubmission"                  \
    -d "id=$ID"                                 \
    -d "userid=33045"                           \
    -d "sesskey=$SESSKEY"                       \
    -d "_qf__mod_assign_submission_form=1"      \
    -d "files_filemanager=$ITEM_ID"             \
    -d "mform_isexpanded_id_submissionheader=1" \
    -L https://edu.mmcs.sfedu.ru/mod/assign/view.php > /dev/null

echo "Готово! 😊"

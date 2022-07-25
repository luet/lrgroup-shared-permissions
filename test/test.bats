#!/usr/bin/env bats 

# set -o pipefail
DATA_DIR="david data"
DEST_DIR="/projects/GEOCLIM/LRGROUP/david-testing/"
FILE="Here is A Space.txt"

function build-data {
    mkdir "$DATA_DIR"
    cd "${DATA_DIR}"
    mkdir dir1 dir2
    dd if=/dev/urandom of=dir1/file1-1 bs=1MB count=1
    dd if=/dev/urandom of=dir1/file1-2 bs=1MB count=1

    dd if=/dev/urandom of=dir2/file2-1 bs=1MB count=1
    dd if=/dev/urandom of=dir2/file2-3 bs=1MB count=1

    # Add a file with a space in the name
    dd if=/dev/urandom of="Here is A Space.txt" bs=1MB count=1
    
    # add absolute path link to file within the data
    CWD=`pwd`
    ln -s "${CWD}"/dir1 l-dir1

    # add link outside what will be dowloaded
    ln -s /home/luet/.tmux
    cd ..
    CWD=`pwd`

    # change the permissions
    chmod -R og-rwx "${DATA_DIR}"
}

function cleanup-test {
    CWD=`pwd`
    echo CWD: "${CWD}"
    rm -Rf "${DATA_DIR}"
    rm -Rf "${DEST}/*"

}


@test "copy a directory and check that the data is there" {
    CWD=`pwd`
    cleanup-test
    build-data

    # copy data to destination
    ../cp-lrgroup "${DATA_DIR}" "${DEST_DIR}"
    
    diff -r "${DATA_DIR}" "{$DEST_DIR}"
    
    [ $status -eq 0 ]
}

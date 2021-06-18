#!/bin/bash

#
# @note
#   This script should be set as "CMD" of "ENTRY_POINT" in your Dockerfile
#
# @note
#   dumb-init is already specified in the Dockerfile as ENTRYPOINT
#   Otherwise use: #!/usr/bin/dumb-init /bin/bash
#

echo
echo "Running [run.sh] from image [hkdigital-nodejs-2021a]"
echo "- $(date)"

echo
echo "Setup nodejs user"

# .................................................................. NodeJS User

USER="nodejs"
id "${USER}" &> /dev/null || useradd "${USER}"

usermod -u 1000 "${USER}"
groupmod -g 1001 "${USER}"

passwd -d "${USER}"

MIN_RUN_TIME_MS=5000

# .................................................................. Root folder

echo
echo "Setup root folder"

if [ -z "${ROOT_FOLDER}" ];
then
  ROOT_FOLDER="/mnt";
fi

if [ ! -d "${ROOT_FOLDER}" ];
then
  mkdir -p "${ROOT_FOLDER}"
fi

echo "- Using ROOT_FOLDER=${ROOT_FOLDER}"

# ...................................................... NodeJS (project) folder

echo
echo "Setup NodeJS project folder"

if [ -z "${PROJECT_NAME}" ];
then
  PROJECT_NAME="nodejs";
fi

PROJECT_FOLDER="${ROOT_FOLDER}/${PROJECT_NAME}"

if [ ! -d "${PROJECT_FOLDER}" ];
then
  mkdir -p "${PROJECT_FOLDER}"
fi

echo "- Using PROJECT_FOLDER=${PROJECT_FOLDER}"

# ...................................................................... Logging

echo
echo "Setup log folder"

if [ -z "${LOG_FOLDER}" ];
then
  LOG_FOLDER="${ROOT_FOLDER}/log"
fi

if [ ! -d "$LOG_FOLDER" ];
then
  echo "- Creating log folder [${LOG_FOLDER}]..."
  mkdir -p "$LOG_FOLDER"
fi

echo "- Updating log folder filesystem rights..."

chown -R "${USER}:${USER}" "$LOG_FOLDER"

find ${LOG_FOLDER}/ -type f -print0 | xargs -0 --no-run-if-empty chmod 0660
find ${LOG_FOLDER}/ -type d -print0 | xargs -0 --no-run-if-empty chmod 0770

LOG_FILE_PATH="${LOG_FOLDER}/${PROJECT_NAME}.log"

echo "- Logging NodeJS output to [${LOG_FILE_PATH}]"

# ................................................................. YARN Install

echo
echo "Checking folder [node_modules]"

cd "${PROJECT_FOLDER}"

if [ -f "${PROJECT_FOLDER}/package.json" ] && [ ! -d "${PROJECT_FOLDER}/node_modules" ];
then
  echo "- Detected [package.json]"
  echo "- Folder [node_modules] does not exist yet"

  CWD=$PWD

  echo "- Running [yarn install] in folder [${CWD}]"
  yarn install --unsafe-perm

  # DEPRECEATED: use bundler!
  # echo "- Running [yarn install] for all library packages in [/lib]"
  # find ./libs/* -maxdepth 1 -name package.json -execdir yarn install --unsafe-perm \;

  cd "$CWD"

  if [ -f "${PROJECT_FOLDER}/link-libs.sh" ];
  then
    echo "- Running [link-libs.sh] in folder [${CWD}]"
    "${PROJECT_FOLDER}/link-libs.sh"
  fi

else
  echo "- Folder [node_modules] exists"
  echo "- Skipping [yarn install]"
fi

# ................................................................. Start NodeJS

echo
echo "Starting NodeJS"

# Find index script

INDEX_JS="${PROJECT_FOLDER}/index.js"

if [ ! -f "${INDEX_JS}" ];
then
  INDEX_JS="${PROJECT_FOLDER}/index.mjs"
fi

if [ ! -f "${INDEX_JS}" ];
then
  INDEX_JS="${PROJECT_FOLDER}/index.cjs"
fi

if [ ! -f "${INDEX_JS}" ];
then
  INDEX_JS="${PROJECT_FOLDER}/dist/index.js"
fi

if [ ! -f "${INDEX_JS}" ];
then
  INDEX_JS="${PROJECT_FOLDER}/dist/index.mjs"
fi

if [ ! -f "${INDEX_JS}" ];
then
  INDEX_JS="${PROJECT_FOLDER}/dist/index.cjs"
fi

if [ -z "${HEAP_SIZE_MB}" ];
then
  HEAP_SIZE_MB=512
fi

if [ "${WATCH}" == "1" ] || [ "${WATCH}" == "true" ];
then
  NODE_CMD="nodemon"
else
  NODE_CMD="node"
fi

STARTTIME=$(date +%s%3N)

if [ -f "${INDEX_JS}" ];
then
  if [ -z "${PARAMS}" ];
  then
    PARAMS=""
  fi

  echo "- Executing [${INDEX_JS}] using [${NODE_CMD}]"
  echo

  IFS=" " read -ra PARAMS_ARR <<<"${PARAMS}"

  #
  # sudo -E -> keep most environment variables
  # sudo -u ${USER} -> execute as the specified user
  #
  # nodejs parameters
  # --use_strict
  # --max-old-space-size=4096
  # --expose-gc
  #
  sudo -E -u "${USER}" "${NODE_CMD}" \
          --use_strict \
          --max-old-space-size=${HEAP_SIZE_MB} \
          "${INDEX_JS}" \
          "${PARAMS_ARR[0]}" \
          "${PARAMS_ARR[1]}" \
          "${PARAMS_ARR[2]}" \
          "${PARAMS_ARR[3]}" \
          "${PARAMS_ARR[4]}" \
          "${PARAMS_ARR[5]}" \
          "${PARAMS_ARR[6]}" \
          "${PARAMS_ARR[7]}" \
          "${PARAMS_ARR[8]}" \
          "${PARAMS_ARR[9]}" |& tee -a "${LOG_FILE_PATH}"
else
  echo
  echo "[!] Javascript file not found"
  echo "    tried index.js, index.mjs, index.cjs"
  echo "          dist/index.js, dist/index.mjs and dist/index.cjs"
  echo
  echo "Sleep infinity..."
  sudo -u "${USER}" sleep infinity
fi

ENDTIME=$(date +%s%3N)

if (( ENDTIME - STARTTIME < MIN_RUN_TIME_MS )); then
  echo
  echo "[!] NodeJS did run for less than ${MIN_RUN_TIME_MS} ms"
  echo
  echo "Sleep infinity..."
  sudo -u "${USER}" sleep infinity
fi

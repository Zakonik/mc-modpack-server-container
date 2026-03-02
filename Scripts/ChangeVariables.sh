#!/bin/bash

set -euo pipefail

VARIABLE_PATH=$SERVER_PATH/variables.txt

if [ -e "$VARIABLE_PATH" ]; then

    echo "Change $VARIABLE_PATH"
    sed -i 's/WAIT_FOR_USER_INPUT=true/WAIT_FOR_USER_INPUT=false/' "$VARIABLE_PATH"
    sed -i 's/SKIP_JAVA_CHECK=false/SKIP_JAVA_CHECK=true/' "$VARIABLE_PATH"
    sed -i "s/JAVA_ARGS=\"-Xmx4G -Xms4G\"/JAVA_ARGS=\"-Xmx${JVM_XMX} -Xms${JVM_XMS} \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+UnlockDiagnosticVMOptions \
  -XX:+UseZGC \
  -XX:+ZGenerational \
  -XX:-ZUncommit \
  -XX:+AlwaysPreTouch \
  -XX:+AlwaysActAsServerClassMachine \
  -XX:+DisableExplicitGC \
  -XX:ReservedCodeCacheSize=400M \
  -XX:+PerfDisableSharedMem \
  -XX:+ParallelRefProcEnabled \
  -XX:+UseStringDeduplication \
  -XX:+EliminateLocks \
  -XX:+DoEscapeAnalysis \
  -XX:+OptimizeStringConcat \
  -XX:+UseCompressedOops \
  -XX:+OmitStackTraceInFastThrow \
  -XX:+SegmentedCodeCache \
  -Dfile.encoding=UTF-8\"/" "$VARIABLE_PATH"

    echo "Variables changed"
fi
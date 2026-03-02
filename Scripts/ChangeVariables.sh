#!/bin/bash

set -euo pipefail

VARIABLE_PATH=$SERVER_PATH/variables.txt

if [ -e "$VARIABLE_PATH" ]; then

    echo "Change $VARIABLE_PATH"
    sed -i 's/WAIT_FOR_USER_INPUT=true/WAIT_FOR_USER_INPUT=false/' "$VARIABLE_PATH"
    sed -i 's/SKIP_JAVA_CHECK=false/SKIP_JAVA_CHECK=true/' "$VARIABLE_PATH"

    sed -i "s/-Xmx[0-9]*[GgMm]/-Xmx${JVM_XMX}/" "$VARIABLE_PATH"

    sed -i "s/-Xms[0-9]*[GgMm]/-Xms${JVM_XMS}/" "$VARIABLE_PATH"

    JVM_EXTRA_FLAGS="\
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
      -Dfile.encoding=UTF-8"

    sed -i "/^JAVA_ARGS=/ s|\"$| ${JVM_EXTRA_FLAGS}\"|" "$VARIABLE_PATH"

    echo "Variables changed"
fi

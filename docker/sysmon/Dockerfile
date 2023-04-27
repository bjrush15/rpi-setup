from alpine:latest
arg SYSMON_BRANCH
run echo Using version $SYSMON_BRANCH
run apk update && apk add python3 git py3-pip
run apk add gcc python3-dev linux-headers musl-dev # add requirements for psutil
workdir /
run git clone -b $SYSMON_BRANCH https://github.com/bjrush15/sysmon
workdir /sysmon
run pip install -r requirements.txt

cmd python3 main.py


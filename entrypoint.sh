#!/bin/sh

DIR_CONFIG="/etc/x"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

cat << EOF > ${DIR_TMP}/config.json
{
    "inbounds": [{
        "port": ${PORT},
        "protocol": "vmess",
        "settings": {
            "clients": [{
                "id": "${ID}"
            }]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "${WSPATH}"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL -k https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o ${DIR_TMP}/hello.zip
busybox unzip ${DIR_TMP}/hello.zip -d ${DIR_TMP}

mkdir -p ${DIR_CONFIG}
cat ${DIR_TMP}/config.json > ${DIR_CONFIG}/config.json

install -m 755 ${DIR_TMP}/x ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

${DIR_RUNTIME}/xray -config=${DIR_CONFIG}/config.json &

sleep 1

rm -rf ${DIR_RUNTIME}/* ${DIR_CONFIG}/*
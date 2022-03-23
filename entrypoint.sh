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

curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL -k github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o ${DIR_TMP}/hello.zip
busybox unzip ${DIR_TMP}/hello.zip -d ${DIR_TMP}

mkdir -p ${DIR_CONFIG}
chmod +x ${DIR_TMP}/v2ctl
${DIR_TMP}/v2ctl config ${DIR_TMP}/config.json > ${DIR_CONFIG}/config.pb

cd ${DIR_TMP}/
mv v2ray x

cp -ar ${DIR_TMP}/x ${DIR_RUNTIME}
chmod +x ${DIR_RUNTIME}/x
rm -rf ${DIR_TMP}

${DIR_RUNTIME}/x -config ${DIR_CONFIG}/config.pb

#!/bin/sh
# Always resolve MANAGER_IP via DNS so proxy works with or without docker.sock (e.g. after Umbrel restart).
MANAGER_IP=$(node -e "try{console.log(require('dns').lookupSync('auth',{family:4}))}catch(e){}" 2>/dev/null)
if [ -z "$MANAGER_IP" ]; then
  SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
  if [ -S "$SOCK" ]; then
    node -e "
    const net=require('net'); const fs=require('fs');
    const s=net.connect('$SOCK');
    s.write('GET /containers/auth/json HTTP/1.0\r\nHost: localhost\r\n\r\n');
    let buf=''; s.on('data',c=>buf+=c); s.on('end',()=>{
      const b=(buf.split('\r\n\r\n')[1]||'');
      try{const d=JSON.parse(b);const n=d.NetworkSettings&&d.NetworkSettings.Networks;if(n){const v=Object.values(n)[0];if(v&&v.IPAddress)fs.writeFileSync('/tmp/mip',v.IPAddress)}}catch(e){}
    }); s.on('error',()=>{});
    " 2>/dev/null
    sleep 2
    [ -f /tmp/mip ] && MANAGER_IP=$(cat /tmp/mip) && rm -f /tmp/mip
    if [ -z "$MANAGER_IP" ]; then
      node -e "
      const net=require('net'); const fs=require('fs');
      const s=net.connect('$SOCK');
      s.write('GET /containers/auth/json HTTP/1.0\r\nHost: localhost\r\n\r\n');
      let buf=''; s.on('data',c=>buf+=c); s.on('end',()=>{
        try{const d=JSON.parse((buf.split('\r\n\r\n')[1]||''));const e=d.Config&&d.Config.Env||[];e.filter(x=>x.startsWith('UMBREL_AUTH_SECRET=')||x.startsWith('JWT_SECRET=')).forEach(x=>fs.appendFileSync('/tmp/env','export '+x+'\n'))}catch(e){}
      }); s.on('error',()=>{});
      " 2>/dev/null
      sleep 1
      [ -f /tmp/env ] && . /tmp/env 2>/dev/null; rm -f /tmp/env
    fi
  fi
fi
[ -z "$MANAGER_IP" ] && MANAGER_IP=$(node -e "try{console.log(require('dns').lookupSync('auth',{family:4}))}catch(e){}" 2>/dev/null)
[ -z "$MANAGER_IP" ] && MANAGER_IP=172.17.0.1
[ -f /run/umbrel-secrets/jwt ] && export JWT_SECRET=$(cat /run/umbrel-secrets/jwt)
[ -z "$UMBREL_AUTH_SECRET" ] && export UMBREL_AUTH_SECRET=default
[ -z "$JWT_SECRET" ] && export JWT_SECRET=default
export MANAGER_IP
export MANAGER_PORT=${MANAGER_PORT:-3006}
export AUTH_SERVICE_PORT=${AUTH_SERVICE_PORT:-2000}
export PROXY_AUTH_ADD=${PROXY_AUTH_ADD:-false}
exec node ./bin/www

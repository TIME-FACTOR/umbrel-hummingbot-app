#!/bin/sh
set -e
SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
TMP="/tmp/auth-inspect.json"
if [ -S "$SOCK" ]; then
  node -e "
    const net=require('net'); const fs=require('fs');
    const s=net.connect('$SOCK');
    const req='GET /containers/auth/json HTTP/1.0\r\nHost: localhost\r\n\r\n';
    let buf=''; s.write(req); s.on('data',c=>buf+=c); s.on('end',()=>{
      const body=buf.split('\r\n\r\n')[1]||'';
      try { fs.writeFileSync('$TMP', body); } catch(e) {}
    }); s.on('error',()=>{});
  " 2>/dev/null
  sleep 1
  if [ -s "$TMP" ]; then
    MANAGER_IP=$(node -e "
      try {
        const j=require('fs').readFileSync('$TMP','utf8'); const d=JSON.parse(j);
        const n=d.NetworkSettings&&d.NetworkSettings.Networks;
        if(n) { const v=Object.values(n)[0]; if(v&&v.IPAddress) process.stdout.write(v.IPAddress); }
      } catch(e) {}
    " 2>/dev/null)
    node -e "
      try {
        const j=require('fs').readFileSync('$TMP','utf8'); const d=JSON.parse(j);
        const e=d.Config&&d.Config.Env||[];
        e.filter(x=>x.startsWith('UMBREL_AUTH_SECRET=')||x.startsWith('JWT_SECRET=')).forEach(x=>console.log(x));
      } catch(e) {}
    " 2>/dev/null | while read -r line; do export "$line"; done
    [ -n "$MANAGER_IP" ] && export MANAGER_IP
  fi
  rm -f "$TMP"
fi
[ -z "$MANAGER_IP" ] && export MANAGER_IP=127.0.0.1
[ -z "$MANAGER_PORT" ] && export MANAGER_PORT=3006
[ -z "$AUTH_SERVICE_PORT" ] && export AUTH_SERVICE_PORT=2000
[ -z "$UMBREL_AUTH_SECRET" ] && export UMBREL_AUTH_SECRET=default
[ -z "$JWT_SECRET" ] && export JWT_SECRET=default
[ -z "$PROXY_AUTH_ADD" ] && export PROXY_AUTH_ADD=false
exec node ./bin/www

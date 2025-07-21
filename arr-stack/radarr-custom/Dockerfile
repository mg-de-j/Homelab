# Gebruik het officiële image als basis
FROM lscr.io/linuxserver/radarr:latest

# Schakel naar root om software te installeren
USER root

# Installeer MakeMKV en ruim daarna op
RUN apk update && \
    apk add --no-cache makemkv

# Maak de scriptmap en kopieer het script erin
RUN mkdir -p /scripts
COPY remux-iso.sh /scripts/remux-iso.sh

# Maak het script uitvoerbaar
RUN chmod +x /scripts/remux-iso.sh

# Schakel terug naar de standaard gebruiker
USER abc
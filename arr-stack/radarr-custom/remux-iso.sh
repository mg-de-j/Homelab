#!/bin/bash

MAKEMKVCON_PATH="/usr/bin/makemkvcon"
# Log naar de /config map die je al hebt gemapt in je docker-compose
LOG_FILE="/config/logs/remux-script.log"
DELETE_ORIGINAL_ISO=true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1" | tee -a "$LOG_FILE"
}

log "--- Script gestart (Event: $radarr_eventtype) ---"

# Controleer of Radarr een bestandspad heeft meegegeven
if [ -z "$radarr_moviefile_path" ]; then
    log "FOUT: radarr_moviefile_path is leeg. Script stopt."
    exit 1
fi

# Controleer of het een .iso bestand is
if [[ "$radarr_moviefile_path" != *.iso ]]; then
    log "INFO: Bestand '$radarr_moviefile_path' is geen .iso, geen actie nodig."
    exit 0
fi

INPUT_ISO="$radarr_moviefile_path"
OUTPUT_DIR=$(dirname "$INPUT_ISO")
# Gebruik een tijdelijke naam om conflicten te voorkomen
TEMP_MKV_NAME=$(basename "$INPUT_ISO" .iso)".REMUX-TEMP.mkv"
TEMP_MKV_PATH="$OUTPUT_DIR/$TEMP_MKV_NAME"

log "Start remux van '$INPUT_ISO' naar '$TEMP_MKV_PATH'"
# Remux de langste titel (meestal de hoofdfilm, aangeduid met '0')
"$MAKEMKVCON_PATH" mkv iso:"$INPUT_ISO" 0 "$TEMP_MKV_PATH" -r --progress=-same >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
    log "FOUT: MakeMKV mislukt. Zie log hierboven. Tijdelijk bestand wordt verwijderd."
    rm -f "$TEMP_MKV_PATH"
    exit 1
fi

log "SUCCES: MakeMKV remux voltooid."

if [ "$DELETE_ORIGINAL_ISO" = true ]; then
    log "Verwijderen van origineel: $INPUT_ISO"
    rm -f "$INPUT_ISO"
fi

# Hernoem het tijdelijke bestand naar de definitieve naam die Radarr verwacht
FINAL_MKV_NAME=$(basename "$INPUT_ISO" .iso)".mkv"
FINAL_MKV_PATH="$OUTPUT_DIR/$FINAL_MKV_NAME"
mv "$TEMP_MKV_PATH" "$FINAL_MKV_PATH"

log "Definitief bestand aangemaakt: $FINAL_MKV_PATH"
log "--- Script voltooid ---"
exit 0
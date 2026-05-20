#!/bin/bash

# Definisi Variabel Jalur File (File Path)
INPUT_FILE="input/domains.txt"
ALL_SUBDOMAINS="output/all-subdomains.txt"
LIVE_OUTPUT="output/live.txt"
PROGRESS_LOG="logs/progress.log"
ERROR_LOG="logs/errors.log"

# Validasi Keberadaan File Input
if [ ! -f "$INPUT_FILE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: File $INPUT_FILE tidak ditemukan!" | tee -a "$ERROR_LOG"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] START: Memulai Pipeline Otomasi Recon" | tee -a "$PROGRESS_LOG"

# Loop Membaca Baris Per Baris di File input/domains.txt
while read -r DOMAIN || [ -n "$DOMAIN" ]; do
    # Lewati baris kosong atau komentar
    [[ -z "$DOMAIN" || "$DOMAIN" =~ ^# ]] && continue

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] PROCESSING: Menjalankan Subfinder untuk $DOMAIN" | tee -a "$PROGRESS_LOG"
    
    # Menjalankan subfinder secara pasif, mengalirkan stderr ke error.log, 
    # dan memfilter hasil unik ke output menggunakan anew (deduplikasi data)
    subfinder -d "$DOMAIN" -silent 2>>"$ERROR_LOG" | anew "$ALL_SUBDOMAINS" >> /dev/null

done < "$INPUT_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] PROBING: Memeriksa Live Hosts dengan httpx" | tee -a "$PROGRESS_LOG"

# Jika file subdomains hasil kompilasi ada, lakukan probing validasi host aktif
if [ -f "$ALL_SUBDOMAINS" ]; then
    # httpx memfilter host aktif, menampilkan status code & title, lalu menyimpan ke live.txt
    cat "$ALL_SUBDOMAINS" | httpx -status-code -title -silent -o "$LIVE_OUTPUT" 2>>"$ERROR_LOG"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Tidak ada subdomain ditemukan." | tee -a "$PROGRESS_LOG"
fi

# Hitung statistik akhir untuk logging
TOTAL_UNIQ=$(wc -l < "$ALL_SUBDOMAINS" 2>/dev/null || echo 0)
TOTAL_LIVE=$(wc -l < "$LIVE_OUTPUT" 2>/dev/null || echo 0)

echo "[$(date '+%Y-%m-%d %H:%M:%S')] DONE: Seluruh Proses Selesai!" | tee -a "$PROGRESS_LOG"
echo "--------------------------------------------------" | tee -a "$PROGRESS_LOG"
echo "Total Subdomain Unik: $TOTAL_UNIQ" | tee -a "$PROGRESS_LOG"
echo "Total Live Hosts    : $TOTAL_LIVE" | tee -a "$PROGRESS_LOG"
echo "--------------------------------------------------" | tee -a "$PROGRESS_LOG"

#!/bin/sh
# Waybar: current weather, from a choice of free sources (no API key).
#   weather.sh          → JSON for waybar
#   weather.sh next     → switch to the next source and refresh the bar (right click)
#   weather.sh full     → full forecast in a terminal (left click)
#
# Default location is Liberdade, São Paulo. Override per machine (not versioned) in
# ~/.config/waybar/weather.local, e.g.:
#   WEATHER_NAME="Curitiba/PR"
#   WEATHER_LAT="-25.4284"
#   WEATHER_LON="-49.2733"
#   WEATHER_CPTEC_ID="227"            # city id: https://brasilapi.com.br/api/cptec/v1/cidade/<nome>
#   WEATHER_PROVIDER="misto"          # misto | open-meteo | cptec | met-no | wttr
#   (misto = forecast from CPTEC/INPE, current conditions and UV from Open-Meteo)
WEATHER_NAME="Liberdade, São Paulo"
WEATHER_LAT="-23.5666"
WEATHER_LON="-46.6319"
WEATHER_CPTEC_ID="244"   # São Paulo (CPTEC has no per-neighbourhood forecast)
WEATHER_PROVIDER="misto"
[ -f "$HOME/.config/waybar/weather.local" ] && . "$HOME/.config/waybar/weather.local"

PROVIDERS="misto open-meteo cptec met-no wttr"
# Right-click choice lasts until logout/reboot, then the default above applies again.
state="${XDG_RUNTIME_DIR:-/tmp}/waybar-weather-provider"
[ -s "$state" ] && WEATHER_PROVIDER=$(cat "$state")

if [ "$1" = next ]; then
    next=$(printf '%s\n' $PROVIDERS $PROVIDERS | awk -v cur="$WEATHER_PROVIDER" 'f{print; exit} $0==cur{f=1}')
    mkdir -p "$(dirname "$state")"; printf '%s\n' "${next:-misto}" > "$state"
    pkill -RTMIN+10 waybar; exit
fi
if [ "$1" = full ]; then
    curl -s "https://wttr.in/${WEATHER_LAT},${WEATHER_LON}?lang=pt&F"; read -r _; exit
fi

offline() { printf '{"text":"󰖪","class":"offline","tooltip":"Clima indisponível: nenhuma fonte respondeu"}\n'; exit 0; }
# On failure prints nothing, so the provider yields empty output and the next source is tried.
get() { curl -sf --max-time 10 -A "waybar-weather/1.0" "$1"; }

# CPTEC/INPE via BrasilAPI: daily forecast only (no current temperature).
cptec_norm() {
    get "https://brasilapi.com.br/api/cptec/v1/clima/previsao/$WEATHER_CPTEC_ID/4" | jq -c '
      # CPTEC condition code → WMO code
      def wmo: if . == "cl" then 0 elif . == "ps" then 1 elif (. == "pn" or . == "vn") then 2
               elif (. == "e" or . == "n") then 3 elif . == "nv" then 45 elif . == "cv" then 51
               elif (. == "g" or . == "ne") then 71 elif . == "t" then 95
               elif test("^(pc|pt|pm|pnt|np|pp)") then 80 else 61 end;
      .clima as $c
      | { code: ($c[0].condicao | wmo), desc: $c[0].condicao_desc, uv: $c[0].indice_uv,
          days: [$c[] | {d: .data, code: (.condicao | wmo), min, max, desc: .condicao_desc}] }'
}
open_meteo_norm() {
    get "https://api.open-meteo.com/v1/forecast?latitude=$WEATHER_LAT&longitude=$WEATHER_LON&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,uv_index_max&timezone=auto&forecast_days=3" | jq -c '
      { temp: .current.temperature_2m, feels: .current.apparent_temperature,
        hum: .current.relative_humidity_2m, wind: .current.wind_speed_10m, code: .current.weather_code, uv: .daily.uv_index_max[0],
        days: [range(0; .daily.time|length) as $i
               | {d: .daily.time[$i], code: .daily.weather_code[$i],
                  min: .daily.temperature_2m_min[$i], max: .daily.temperature_2m_max[$i]}] }'
}

# Each provider is reduced to one shape:
# {temp?, feels?, hum?, wind?, uv?, code, desc?, today?, days:[{d, code, min, max, desc?}]} where code is a WMO weather code.
fetch() {
  norm=""
  case "$1" in
  cptec)
    label="CPTEC/INPE"; norm=$(cptec_norm) ;;
  misto)
    label="CPTEC/INPE + Open-Meteo"
    cp=$(cptec_norm); om=$(open_meteo_norm)
    [ -n "$cp" ] && [ -n "$om" ] || return 1
    # current conditions + UV from Open-Meteo, forecast and today's summary from INPE
    norm=$(jq -nc --argjson cp "$cp" --argjson om "$om" '$om + {today: $cp.desc, days: $cp.days, mixed: true}') ;;
  open-meteo)
    label="Open-Meteo"; norm=$(open_meteo_norm) ;;
  met-no)
    label="MET Norway"
    off=$(date +%z | awk '{print (substr($0,1,1)=="-"?-1:1) * (substr($0,2,2)*3600 + substr($0,4,2)*60)}')
    norm=$(get "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=$WEATHER_LAT&lon=$WEATHER_LON" | jq -c --argjson off "$off" '
      # yr.no symbol → WMO code
      def wmo: (sub("_(day|night|polartwilight)$"; "")) as $s
        | if $s == "clearsky" then 0 elif $s == "fair" then 1 elif $s == "partlycloudy" then 2
          elif $s == "cloudy" then 3 elif $s == "fog" then 45
          elif ($s|test("thunder")) then 95 elif ($s|test("snow|sleet")) then 71
          elif ($s|test("showers")) then 80 elif ($s|test("drizzle")) then 51
          elif ($s|test("rain")) then 61 else 3 end;
      .properties.timeseries as $t
      | $t[0] as $n
      | { temp: $n.data.instant.details.air_temperature,
          hum: $n.data.instant.details.relative_humidity,
          wind: ($n.data.instant.details.wind_speed * 3.6),
          code: (($n.data.next_1_hours // $n.data.next_6_hours).summary.symbol_code | wmo),
          days: ( $t | map(. + {local: ((.time|fromdateiso8601) + $off)})
                  | group_by(.local | strftime("%Y-%m-%d")) | .[:3]
                  | map({ d: (.[0].local | strftime("%Y-%m-%d")),
                          min: (map(.data.instant.details.air_temperature) | min),
                          max: (map(.data.instant.details.air_temperature) | max),
                          code: ((map(select((.local|strftime("%H")) == "12")) + .)[0]
                                 | (.data.next_6_hours // .data.next_1_hours).summary.symbol_code // "cloudy" | wmo) }) ) }') ;;
  wttr)
    label="wttr.in"
    norm=$(get "https://wttr.in/${WEATHER_LAT},${WEATHER_LON}?format=j1" | jq -c '
      # wttr (WWO) code → WMO code
      def wmo: tonumber as $c
        | if $c == 113 then 0 elif $c == 116 then 2 elif ($c == 119 or $c == 122) then 3
          elif ([$c] | inside([143,248,260])) then 45
          elif ([$c] | inside([200,386,389,392,395])) then 95
          elif ([$c] | inside([179,227,230,323,326,329,332,335,338,368,371])) then 71
          elif ([$c] | inside([263,266,281,284])) then 51
          elif ([$c] | inside([353,356,359])) then 80 else 61 end;
      .current_condition[0] as $c
      | { temp: ($c.temp_C|tonumber), feels: ($c.FeelsLikeC|tonumber), hum: ($c.humidity|tonumber),
          wind: ($c.windspeedKmph|tonumber), code: ($c.weatherCode|wmo),
          days: [.weather[] | {d: .date, code: (.hourly[4].weatherCode|wmo),
                               min: (.mintempC|tonumber), max: (.maxtempC|tonumber)}] }') ;;
    *) return 1 ;;
  esac
  [ -n "$norm" ]
}

# Try the chosen source first; if it fails, fall back through the others.
# misto is never a fallback (it needs both INPE and Open-Meteo); cptec-only goes last (no current temp).
FALLBACK="open-meteo met-no wttr cptec"
case " $PROVIDERS " in *" $WEATHER_PROVIDER "*) ;; *) WEATHER_PROVIDER=misto ;; esac
chosen="$WEATHER_PROVIDER"; used=""
case "$chosen" in
    open-meteo) chosen_name="Open-Meteo" ;; misto) chosen_name="Misto (INPE + Open-Meteo)" ;;
    cptec) chosen_name="CPTEC/INPE" ;; met-no) chosen_name="MET Norway" ;; *) chosen_name="wttr.in" ;;
esac
for p in "$chosen" $FALLBACK; do
    [ "$p" = "$chosen" ] && [ -n "$used$tried" ] && continue
    tried=1
    if fetch "$p"; then used="$p"; break; fi
done
[ -n "$used" ] || offline

hour=$(date +%H)
printf '%s' "$norm" | jq -c --arg place "$WEATHER_NAME" --arg src "$label" --arg cls "$used" --arg chosen "$chosen_name" --arg fallback "$( [ "$used" != "$chosen" ] && echo yes )" \
  --argjson night "$( [ "$hour" -ge 18 ] || [ "$hour" -lt 6 ] && echo true || echo false )" '
  def icon: if . == 0 then "󰖙" elif . <= 2 then "󰖕" elif . == 3 then "󰖐" elif . <= 48 then "󰖑"
            elif . <= 57 then "󰖗" elif . <= 67 then "󰖗" elif . <= 77 then "󰖘" elif . <= 82 then "󰖖"
            elif . <= 86 then "󰖘" else "󰙾" end;
  def desc: if . == 0 then "Céu limpo" elif . == 1 then "Predomínio de sol" elif . == 2 then "Parcialmente nublado"
            elif . == 3 then "Nublado" elif . <= 48 then "Neblina" elif . <= 57 then "Garoa"
            elif . <= 67 then "Chuva" elif . <= 77 then "Neve" elif . <= 82 then "Pancadas de chuva"
            elif . <= 86 then "Neve" else "Trovoada" end;
  def r: round | tostring;
  # "2026-11-18" → "18/nov"
  def ddmon: (.[5:7] | tonumber) as $m
    | .[8:10] + "/" + (["jan","fev","mar","abr","mai","jun","jul","ago","set","out","nov","dez"][$m - 1]);
  # moon instead of sun for clear / partly cloudy skies at night
  def nowicon: if $night and . == 0 then "󰖔" elif $night and . <= 2 then "󰼱" else icon end;
  { text: (if .temp then "\(.code|nowicon) \(.temp|r)°"
            else "\(.code|icon) \(.days[0].min|r)°/\(.days[0].max|r)°" end),
    tooltip: (
      "<b>\($place)</b>  " + (if .temp then "Agora: " else "" end) + "\(.desc // (.code|desc))\n"
      + (if .today then "Ainda hoje: \(.today)\n" else "" end)
      + (if .temp then
           (if .feels then "Sensação \(.feels|r)°  ·  " else "" end)
           + "Umidade \(.hum|r)%  ·  Vento \(.wind|r) km/h"
           + (if (.uv // 0) > 0 then "  ·  UV máx \(.uv|r)" else "" end) + "\n\n"
         else "Previsão do dia (sem temperatura atual)" + (if (.uv // 0) > 0 then "  ·  UV \(.uv)" else "" end) + "\n\n" end)
      + ([.days[] | "\(.d|ddmon)   \(.code|icon)  \(.min|r)° / \(.max|r)°" + (if .desc then "   \(.desc)" else "" end)] | join("\n"))
      + (if .mixed then "\n\n<small>Previsão: CPTEC/INPE · Agora e UV: Open-Meteo · botão direito troca</small>"
         else "\n\n<small>Fonte: \($src) · botão direito troca</small>" end)
      + (if $fallback == "yes" then "\n<small>󰀦 \($chosen) não respondeu, usando \($src)</small>" else "" end)),
    class: (if $fallback == "yes" then [$cls, "fallback"] else $cls end) }'

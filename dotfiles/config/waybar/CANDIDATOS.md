# Waybar — módulos candidatos

Ideias para testar na "faixa". Já em uso: clima, atualizações dnf, uptime, GitHub, clipboard.
Marque com [x] quando adicionar ou risque quando descartar.

## Úteis

- [ ] **Gravação de tela** — ponto vermelho piscando enquanto `wf-recorder`/`gpu-screen-recorder` grava; clique para parar. Fica junto do `privacy`.
- [ ] **Seletor de saída de áudio** — clique alterna fone/caixa (`wpctl`), sem abrir o pavucontrol.
- [ ] **Perfil de energia** — economia / equilibrado / desempenho. Precisa `power-profiles-daemon` (módulo nativo `power-profiles-daemon`).
- [ ] **Luz noturna** — liga/desliga `wlsunset` (tela mais quente à noite).
- [ ] **Pomodoro / timer** — contagem regressiva na barra + notificação do mako no fim.
- [ ] **Contador de notificações** — quantas o mako guardou durante o "não perturbe" (`makoctl history`).
- [ ] **Tráfego de rede** — ↓/↑ ao vivo num drawer, como CPU/RAM.
- [ ] **Disco** — espaço livre em `/` e `/home`; vira alerta acima de 90%.
- [ ] **GPU** — uso e temperatura (`nvidia-smi` ou `/sys/class/drm/*/device/gpu_busy_percent`).
- [ ] **VPN / Tailscale** — ícone quando conectado; clique liga/desliga.
- [ ] **Containers** — número de containers `podman`/`docker` rodando; tooltip com os nomes.
- [ ] **Microfone** — mudo/ativo com clique para alternar, separado do volume de saída.
- [ ] **Bateria de periféricos** — fone/mouse Bluetooth via `upower` (o módulo `upower` nativo faz isso).
- [ ] **Calendário / próximo evento** — próximo compromisso do dia via `khal` ou `gcalcli`.
- [ ] **Fuso horário extra** — segundo relógio no tooltip (ou alternar com clique) para outro país.
- [ ] **Teclado / caps lock** — indicador `keyboard-state` de Caps/Num Lock.
- [ ] **Zoom / ampliação** — atalho para lupa ou modo de leitura.
- [ ] **Scratchpad de notas** — clique abre um arquivo de notas rápidas num terminal flutuante.
- [ ] **Status do backup** — último snapshot do `restic`/`borg`/`btrfs`; alerta se passou de N dias.
- [ ] **Ping / qualidade da conexão** — latência até 1.1.1.1; muda de cor quando a internet piora.
- [ ] **Clima: WeatherAPI.com como 5ª fonte** — entra no fim da fila de fallback. Grátis (1M chamadas/mês) com cadastro; chave fica só no `weather.local` (`WEATHER_WEATHERAPI_KEY`). Traz qualidade do ar e alertas.

## Divertidos

- [ ] **Visualizador de áudio (`cava`)** — barrinhas dançando com a música, ao lado do `mpris`.
- [ ] **Letra da música** — linha atual da música tocando (`playerctl` + API de letras).
- [ ] **Cotação** — dólar / euro / bitcoin em reais, a cada 15 min.
- [ ] **Fase da lua** — ícone muda com a fase; tooltip diz qual é.
- [ ] **Contagem regressiva** — dias até férias, lançamento, fim do ano.
- [ ] **Frase do dia** — `fortune` no tooltip de algum módulo, troca a cada hora.
- [ ] **Pet na barra** — um bichinho ASCII/emoji que muda de humor conforme CPU ou bateria.
- [ ] **Placar ao vivo** — jogo do seu time (API de futebol) durante a partida.
- [ ] **Commits de hoje** — quantos commits você fez hoje nos repos de `~/projects`.
- [ ] **Streak do GitHub** — dias seguidos com contribuição.
- [ ] **Pôr do sol** — horário do nascer/pôr do sol; ícone muda ao entardecer.
- [ ] **Contador de digitação** — teclas pressionadas hoje (precisa daemon de input — cuidado com privacidade).
- [ ] **Wallpaper aleatório** — clique sorteia outro wallpaper via `waypaper`/`awww`.
- [ ] **Cor do dia** — uma cor aleatória da paleta Umbra como acento, trocando por dia.
- [ ] **Estação Espacial** — avisa quando a ISS está passando sobre você.

### Mais divertidos

- [ ] **Gato correndo (estilo RunCat)** — um gatinho animado que corre mais rápido quanto maior o uso de CPU.
- [ ] **Sparkline de CPU/RAM** — mini-gráfico `▁▂▃▅▇` com os últimos minutos, em vez de só a porcentagem.
- [ ] **Progresso do ano** — `▓▓▓▓▓▓▓░░ 88%` do ano (ou do mês / do dia de trabalho).
- [ ] **Próximo feriado** — dias até o próximo feriado nacional (BrasilAPI `/feriados`), sem chave.
- [ ] **Hoje na história** — um fato do dia no tooltip (Wikipedia "On this day", em português).
- [ ] **Foto astronômica do dia (NASA APOD)** — clique abre; botão direito vira wallpaper.
- [ ] **XKCD do dia** — título do último quadrinho; clique abre a imagem.
- [ ] **Próximo lançamento de foguete** — contagem regressiva (Launch Library 2, sem chave).
- [ ] **Aurora / clima espacial** — índice Kp da NOAA; ícone acende em tempestade geomagnética.
- [ ] **Terremotos** — último sismo grande do mundo (feed USGS), magnitude e local.
- [ ] **Pokémon do dia** — nome, número e tipo via PokéAPI, trocando a cada dia.
- [ ] **Dado / moeda** — clique rola um d20 (ou cara/coroa) e mostra o resultado por 5 s.
- [ ] **Relógio diferente** — binário, hexadecimal, Swatch @beats ou "por extenso" (são quase três e meia), alternando com clique.
- [ ] **Hora em Marte** — horário coordenado de Marte (MTC) e o sol marciano atual, calculados localmente.
- [ ] **Contador de cafés / água** — clique soma +1, zera à meia-noite; tooltip mostra a semana.
- [ ] **Lembrete de pausa** — ícone pisca a cada 50 min de uso contínuo (respeita o idle).
- [ ] **Diário de humor** — clique escolhe um emoji do dia (fuzzel); tooltip mostra os últimos 7.
- [ ] **Tempo de tela por app** — app mais usado hoje, medido pela janela em foco (`niri msg`).
- [ ] **Qualidade do ar / pólen** — AQI e pólen da Open-Meteo Air Quality (mesma localização do clima).
- [ ] **Hacker News / RSS** — título do post #1 (ou do seu feed favorito) rolando no tooltip.

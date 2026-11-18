# TODO — o que ainda falta mexer

Checklist do sistema, em duas categorias:

- **Problemas**: algo errado ou inconsistente hoje (cores antigas, valores diferentes entre componentes, configuração fora do repo).
- **Alterações**: personalizações e ferramentas novas que ainda não foram feitas.

Em cada categoria, a ordem é de prioridade: alta → média → baixa.
`[HW]` = só faz sentido em hardware real (não na VM).

Tokens visuais propostos, para usar como referência nos itens de consistência:

| Token | Valor |
|---|---|
| Raio pequeno / médio / grande | 6 / 10 / 12 px |
| Borda fina | 1 px âmbar 30% (`@line`) |
| Borda de foco | 2 px âmbar `#e0a050` |
| Espaço até a borda da tela | 6 px (janelas, barra, notificações) |
| Opacidade de superfícies | 0.94 (`f0`) |
| Fonte da interface | Inter 11 |
| Fonte mono | JetBrainsMono Nerd Font 11 |
| Cores com função fixa | âmbar = foco/ativo; lilás = secundário; surface1 = seleção; vermelho forte `#e5455a` = urgente/erro; amarelo = aviso |
| Animação curta | 150 ms ease-out |
| Sombra | larga e suave: softness 60, spread 8, y 10, `#14031a55` |

## Problemas

Coisas que estão erradas ou inconsistentes hoje. Ordem: prioridade alta → baixa.

### Alta
- [ ] **Configurações em uso que não estão no repo**: `gtk-3.0/gtk.css`, `fish/conf.d/` (cores Umbra, mise), btop (+ tema umbra), `mise/config.toml`, `mpv/script-opts/uosc.conf`, Firefox `userChrome.css`/`userContent.css`/`user.js` (instalar pelo `user.sh` no perfil default-release). Revisar se há dado pessoal antes.
- [x] **Cores do fzf ainda Catppuccin** (`FZF_DEFAULT_OPTS` em `fish/config.fish`) → paleta Umbra.
- [x] **Fontes padrão não batem**: `sans-serif`/`monospace` caem em Noto, enquanto o GTK usa Inter/JetBrainsMono → criar `fontconfig/fonts.conf` com aliases (sans → Inter, mono → JetBrainsMono NF, emoji → Noto Color Emoji).
- [x] **wob (barra de volume/brilho) ainda usa cores Catppuccin** — `wob/wob.ini`: `background_color = 26082ff0`, `border_color = e0a050ff`, `bar_color = e0a050ff`, `overflow_bar_color = e86a7aff`, `overflow_border_color = e86a7aff`, `border_offset = 2`.
- [x] **Apps Qt sem tema** (ex.: configurador do fcitx5 abre claro) — instalar `qt6ct qt5ct` (ou Kvantum), `QT_QPA_PLATFORMTHEME "qt6ct"` no `environment {}` do niri, esquema de cores Umbra, Inter 11, ícones Papirus-Dark.
- [ ] **VS Code ainda é Catppuccin por baixo** (sintaxe, git, ícones; o terminal já é Umbra) — `Code/User/settings.json`: `terminal.ansi*` com as cores do tema Umbra do Ghostty; trocar o tema base ou adicionar `editor.tokenColorCustomizations`.

### Média
- [ ] **herdr com tema `rose-pine`** → tema Umbra (se suportar tema próprio) ou o mais próximo.
- [x] **Login com paleta VGA padrão**: o tuigreet herda as cores do console → paleta Umbra via `vt.default_red/grn/blu` no kernel ou serviço setvtrgb; fonte maior (terminus `ter-v20b`).
- [ ] **Associações de arquivo incompletas** (`mimeapps.list` só define PDF e pastas) → imagens: Loupe; vídeo/áudio: mpv; texto: Text Editor; compactados: File Roller; e versionar o arquivo.
- [x] **Cantos com 6 raios diferentes** (janelas 6, barra 10, tooltip 8, gtklock 9, mako 12, fuzzel 14) — padronizar: janelas/barra/tooltip/gtklock 10, fuzzel/mako 12, detalhes 6.
- [x] **Distância da borda da tela desalinhada** (janelas 5, barra 10, mako 12) — niri `gaps 8`, margens da barra 8, mako `margin=8` (e nos outros presets).
- [x] **Anel de foco mais fraco que os popups** (1 px vs 2 px) — niri `focus-ring { width 2 }`.
- [x] **Cor de urgência/erro diferente em cada lugar** (mako pêssego, waybar vermelho, gtklock #ff7b63) — usar o vermelho `#e86a7a` em todos.
- [x] **Alacritty diferente do Ghostty** (cursor creme, seleção invertida, branco brilhante mais escuro que o normal) — copiar as cores de `ghostty/themes/Umbra`.
- [x] **Tela de bloqueio usa Adwaita Sans**, o resto usa Inter — `gtklock/style.css`: `font-family: "Inter", sans-serif`.
- [x] **Animações diferentes por preset da barra** (refinada/minimal têm, faixa/solida não) — mover `transition: all 150ms ease-out` para `common.css`.

### Baixa
- [ ] Arquivos `*.bak*` / `*.bak-catppuccin` espalhados em `~/.config` → apagar depois de sincronizar.
- [ ] ibus coexistindo com fcitx5 → garantir que o ibus não inicia.
- [ ] `blueman-applet` roda mesmo sem adaptador → só iniciar se houver Bluetooth.
- [ ] Dois tons de fundo quase iguais (`#2a0a33` na barra, `#26082f` no resto) — usar um só.
- [ ] Nomes enganosos na paleta (`mauve` = âmbar, `blue` = lilás; `lilac` duplica `blue`) — renomear/criar aliases em `colors.css`.
- [ ] Cores fora da paleta: popover GTK `#2e0b38`, sombra do niri preto puro, campo do gtklock branco neutro, `dim`/`soft` só na waybar — integrar à paleta.
- [x] Opacidade dos popups varia (0.88–0.94) — padronizar em 0.94 (`f0`).
- [x] Fuzzel usa rosa no texto destacado da seleção (único lugar com rosa) — trocar por âmbar ou amarelo.
- [ ] Preset *solida* usa separadores de outra cor — usar `@line` se não for intencional.
- [x] Waypaper aponta para um `style.css` que não existe — remover a linha; cor de preenchimento `#14031a`.
- [x] Mako e fuzzel sem sombra (janelas têm) — `layer-rule` com `shadow { on; }` no niri.
- [x] Login (tuigreet) sem cores — `--theme` em `system-files/greetd-config.toml`.
- [ ] Cursor do sistema (`/usr/share/icons/default`) ainda Adwaita — apontar para Bibata.
- [ ] Pastas do Papirus azuis, destoam do roxo/âmbar — `papirus-folders -C orange` (ou `violet`).
- [x] niri sem bloco `animations {}` (usa padrões) — fixar valores explícitos para facilitar ajuste.

## Alterações

Personalizações e ferramentas novas. Ordem: prioridade alta → baixa.

### Alta
- [ ] **Volume por app** à mão: instalar `wiremix` (TUI) e abrir pelo clique do meio no ícone de volume; rolar no player de mídia muda só o volume da mídia; atalhos Super+Shift+F10–F12 para a mídia.
- [ ] **Gravação de tela**: `wf-recorder` (ou gpu-screen-recorder em hardware real) + script liga/desliga + indicador na waybar + atalho no niri.
- [ ] **Anotar captura de tela**: `satty`; atalho `grim -g "$(slurp)" - | satty -f -`.
- [ ] **Prompt Starship**: criar `starship.toml` com a paleta Umbra (o Starship já está instalado, mas usa o prompt padrão).
- [ ] **Git**: `git-delta` como pager (tema Umbra) + `merge.conflictstyle=zdiff3`, `rerere`, `diff.algorithm=histogram`, `push.autoSetupRemote`, aliases.
- [x] **Animações do niri**: bloco `animations {}` explícito (abrir janela 200 ms ease-out-cubic, troca de workspace um pouco mais suave) para poder ajustar.

### Média
- [ ] **Som de notificação** no mako (`on-notify=exec pw-play …/message.oga`), mudo no modo não perturbe.
- [ ] **Luz noturna**: `wlsunset` + botão na waybar (talvez não funcione na VM).
- [ ] **Ações no Nemo**: "Abrir Ghostty aqui", "Definir como wallpaper", "Copiar caminho"; instalar `nemo-fileroller`.
- [x] **Limpar o lançador**: esconder do fuzzel htop, mc, nm-connection-editor, Nautilus, ibus e as ferramentas do fcitx/mozc (`NoDisplay=true`).
- [ ] **Tema do fcitx5** (janela de candidatos) em Umbra.
- [ ] **GNOME Text Editor**: esquema de cores Umbra (GtkSourceView 5) e fonte JetBrainsMono.
- [ ] **lazygit**: `config.yml` com cores Umbra e o delta como pager.
- [ ] **eza**: `theme.yml` Umbra.
- [ ] **fastfetch**: `config.jsonc` com cores Umbra (opcional: rodar ao abrir o fish).
- [ ] **fish**: trocar aliases por `abbr`, adicionar funções úteis (mkcd, extract), ativar o hook do direnv.
- [ ] **Bloqueio por inatividade**: escurecer a tela antes de bloquear; tempos mais curtos que 1 h.
- [ ] **Terminal padrão** para apps com `Terminal=true`: `xdg-terminals.list` → ghostty.
- [ ] **Portais**: fixar o seletor de arquivos em `xdg-desktop-portal/niri-portals.conf`.
- [ ] **Tela de boot (Plymouth)**: tema Umbra (hoje está em `text`; na VM depende do framebuffer).
- [ ] **yazi** (gerenciador de arquivos no terminal) com tema Umbra.
- [ ] **Perfis de energia** `[HW]`: `tuned-ppd` + módulo da waybar.

### Baixa
- [ ] Atalhos na barra lateral do Nemo/seletor de arquivos (projetos, Screenshots, Wallpapers).
- [ ] fish: fisher + `done` (notifica quando um comando longo termina).
- [ ] Tema do bat (`.tmTheme` Umbra) e LS_COLORS (vivid).
- [ ] atuin (busca no histórico do shell).
- [ ] Editor no terminal: vimrc mínimo, ou neovim/helix com tema Umbra.
- [ ] GRUB: menu escondido (`GRUB_TIMEOUT_STYLE=hidden`) ou tema.
- [ ] Equalizador (easyeffects) e nomes dos dispositivos de áudio no WirePlumber `[HW]`.
- [ ] Cores do uosc no mpv.
- [ ] Visualizador de PDF próprio (Papers ou zathura) em vez do Firefox.
- [ ] Snapshots btrfs (snapper) antes de mexer em arquivos do sistema.
- [ ] Ação da tampa / suspensão (`logind.conf.d`) `[HW]`.
- [ ] Monitores: escala e taxa de atualização nos blocos `output` do niri `[HW]`.
- [ ] Touchpad: toque e rolagem natural `[HW]`.
- [ ] MangoHud e gamemode com cores Umbra, para `system.sh --gaming` `[HW]`.
- [ ] Mais widgets da barra: ver `dotfiles/config/waybar/CANDIDATOS.md`.

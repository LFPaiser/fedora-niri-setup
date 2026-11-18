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
- [x] **Configurações em uso que não estão no repo**: gtk.css, fish/conf.d, btop (tema), mise, uosc e Firefox (userChrome/userContent/user.js + tema Umbra do AMO pela política) agora estão no repo e o `user.sh` instala.
- [ ] **VS Code igual ao do Windows**: ativar o Settings Sync aqui com a mesma conta (temas, ícones, extensões, perfis). O repo não gerencia mais o VS Code e não aplica Umbra nele.

### Média
- [x] **Associações de arquivo**: `mimeapps.list` no repo, montado a partir dos tipos de cada app — compactados: File Roller; imagens: Loupe; vídeo/áudio: mpv; texto: Text Editor (zip abria no Nautilus).

### Baixa
- [x] Arquivos `*.bak*` antigos em `~/.config` apagados (17, até 17/11). Os de 18/11 ficam até confirmar que está tudo certo.
- [x] Dois tons de fundo quase iguais: a waybar agora usa `#26082f` (`@bg`), o mesmo do resto.
- [ ] Nomes enganosos na paleta (`mauve` = âmbar, `blue` = lilás; `lilac` duplica `blue`) — renomear/criar aliases em `colors.css`.
- [ ] Cores fora da paleta: popover GTK `#2e0b38`, sombra do niri preto puro, campo do gtklock branco neutro, `dim`/`soft` só na waybar — integrar à paleta.
- [ ] Preset *solida* usa separadores de outra cor — usar `@line` se não for intencional.
- [ ] Cursor do sistema (`/usr/share/icons/default`) ainda Adwaita — apontar para Layan-White-Umbra.
- [ ] Pastas do Papirus azuis, destoam do roxo/âmbar — `papirus-folders -C orange` (ou `violet`).

## Alterações

Personalizações e ferramentas novas. Ordem: prioridade alta → baixa.

### Alta
- [ ] **Volume por app** à mão: instalar `wiremix` (TUI) e abrir pelo clique do meio no ícone de volume; rolar no player de mídia muda só o volume da mídia; atalhos Super+Shift+F10–F12 (−, mudo, +) para a mídia.
- [ ] **Gravação de tela**: `wf-recorder` (ou gpu-screen-recorder em hardware real) + script liga/desliga + indicador na waybar + atalho Super+Alt+R (liga/desliga).
- [ ] **Anotar captura de tela**: `satty`; atalho Shift+Print → `grim -g "$(slurp)" - | satty -f -`.
- [ ] **Prompt Starship**: criar `starship.toml` com a paleta Umbra (o Starship já está instalado, mas usa o prompt padrão).
- [ ] **Git**: `git-delta` como pager (tema Umbra) + `merge.conflictstyle=zdiff3`, `rerere`, `diff.algorithm=histogram`, `push.autoSetupRemote`, aliases.

- [ ] **Kitty no lugar do Alacritty** como terminal reserva: usa o mesmo protocolo de imagens do Ghostty (yazi, `icat`), então as ferramentas continuam funcionando ao trocar. Trocar o pacote em `system.sh`, criar `kitty/kitty.conf` com as cores Umbra, atalho no niri; o Foot (`Super+Shift+Enter`) fica como terminal de emergência.
- [ ] **Ghostty pela GPU** `[HW]`: confirmar que em hardware real não existe `/usr/local/bin/ghostty` (o script com `LIBGL_ALWAYS_SOFTWARE=1` é só da VM, que tem OpenGL 4.1 e o Ghostty precisa de 4.3) e que o Ghostty usa a GPU (`ghostty +show-config` / desempenho com muita saída).
- [ ] **Ghostty: instância única ou não** — hoje `gtk-single-instance = detect` põe todas as janelas num processo só; se o Ghostty travar, todas as sessões (ex.: várias do Claude Code) fecham juntas. Decidir entre `false` (um processo por janela) ou manter + tmux/zellij.

### Média
- [ ] **Testar o swaync no lugar do mako**: principal motivo é pausar o tempo da notificação com o mouse em cima (o mako 1.11 não tem); de bônus, central de notificações com histórico. Confirmar a pausa antes de trocar, e ver se ele mostra o tempo restante na notificação (o mako não mostra). Para trocar: tema Umbra em CSS, atalhos Super+N / Shift+N / Ctrl+N, `dnd.sh` da waybar, 4 visíveis, agrupamento por app e o som.
- [ ] **Som de notificação** no mako (`on-notify=exec pw-play …/message.oga`), mudo no modo não perturbe.
- [ ] **Luz noturna**: `wlsunset` + botão na waybar (talvez não funcione na VM).
- [ ] **Ações no Nemo**: "Abrir Ghostty aqui", "Definir como wallpaper", "Copiar caminho"; instalar `nemo-fileroller`.
- [ ] **Tema do fcitx5** (janela de candidatos) em Umbra.
- [ ] **Regras do mako por app** quando aparecerem os casos reais (ex.: player de música com tempo curto e sem som).
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
- [ ] **Janelas de script flutuando**: as janelas Ghostty abertas pela waybar (`Clima`, `Atualizações`, wifi-menu, wiremix) abrem como coluna inteira → `window-rule` por título com `open-floating true` e tamanho fixo.
- [ ] **Detectar diferença entre repo e `~/.config`**: script `scripts/drift.sh` que compara os dotfiles do repo com os instalados e lista o que mudou de um lado ou do outro (evita config viva fora do repo, como no item de Problemas).
- [ ] **Backup do home**: Pika Backup ou restic com timer `systemd --user` (excluir `~/.cache`, `node_modules`, VMs).
- [ ] **Histórico da área de transferência**: limitar o cliphist (`-max-items`), não guardar o que vem de gerenciadores de senha (`x-kde-passwordManagerHint`), atalho para apagar um item ou limpar tudo.
- [ ] **Agente polkit**: o `mate-polkit` abre sem o tema Umbra → testar com o GTK atual ou trocar (ex.: `hyprpolkitagent`, `lxqt-policykit`).
- [ ] **Compartilhar tela**: testar captura de tela/janela no Firefox e no Meet/Discord pelo `xdg-desktop-portal-gnome` e anotar o que funciona.
- [ ] **Apps Flatpak com o tema**: `flatpak override --user` com `GTK_THEME`, acesso a `~/.themes`/`~/.icons`, cursor Layan-White-Umbra e fontes.
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
- [ ] Seletor de emoji (`fuzzel --dmenu` com lista de emojis, Super+Ctrl+Space) e calculadora rápida (`qalc`) pelo fuzzel, com atalho.
- [ ] Atualização de firmware `[HW]`: `fwupdmgr refresh && fwupdmgr update`, ou um aviso na waybar junto com o `updates.sh`.
- [ ] Mais widgets da barra: ver `dotfiles/config/waybar/CANDIDATOS.md`.

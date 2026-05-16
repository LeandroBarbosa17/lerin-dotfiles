#!/bin/bash

player="spotify"
last_metadata=""
cover_dir="/tmp/spotify-cover"
mkdir -p "$cover_dir"

# Função para limpar a capa ao fechar o script
trap "rm -rf $cover_dir" EXIT

while true; do
    # Obtém metadados em uma única chamada para evitar dessincronização
    metadata=$(playerctl --player=$player metadata --format "{{title}} - {{artist}} - {{mpris:artUrl}}" 2>/dev/null)

    if [[ -n "$metadata" && "$metadata" != "$last_metadata" ]]; then
        title=$(playerctl --player=$player metadata xesam:title)
        artist=$(playerctl --player=$player metadata xesam:artist)
        arturl=$(playerctl --player=$player metadata mpris:artUrl)

        # Define o caminho da imagem local
        # Usamos um hash da URL para evitar problemas de cache com a mesma imagem
        cover_path="$cover_dir/cover.png"

        if [[ "$arturl" =~ ^https?:// ]]; then
            curl -s "$arturl" -o "$cover_path"
            cover="$cover_path"
        elif [[ "$arturl" =~ ^file:// ]]; then
            cover="${arturl#file://}"
        else
            cover="spotify" # Fallback para o ícone do sistema
        fi

        # Envia a notificação
        # -h string:x-dunst-stack-tag:spotify -> substitui a notificação anterior com a mesma tag
        # -a "Spotify" -> define o nome do app
        notify-send -a "Spotify" \
                    -i "$cover" \
                    -h string:x-dunst-stack-tag:spotify \
                    "🎵 Tocando agora" \
                    "<b>$title</b>\n$artist"

        last_metadata="$metadata"
    fi

    sleep 1
done

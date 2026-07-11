#!/bin/sh
# =============================================================
# Modulo Xrandr para Filtros de Tela por Tema
# =============================================================

# Aplica o filtro se estiver ativado no tema atual
if [ "$XRANDR_FILTER" = "true" ]; then
    # Detecta automaticamente o monitor principal ativo
    MONITOR=$(xrandr | grep " connected primary" | awk '{print $1}')
    
    # Se não houver 'primary' definida, pega a primeira conectada
    if [ -z "$MONITOR" ]; then
        MONITOR=$(xrandr | grep " connected" | awk '{print $1}' | head -n 1)
    fi

    # Aplica as variáveis personalizadas do tema
    if [ -n "$MONITOR" ]; then
        xrandr --output "$MONITOR" --gamma "$XRANDR_GAMMA" --brightness "$XRANDR_BRIGHTNESS"
    fi
else
    # Se o tema não usar filtro, reseta o monitor para o padrão
    MONITOR=$(xrandr | grep " connected" | awk '{print $1}' | head -n 1)
    if [ -n "$MONITOR" ]; then
        xrandr --output "$MONITOR" --gamma 1:1:1 --brightness 1.0
    fi
fi

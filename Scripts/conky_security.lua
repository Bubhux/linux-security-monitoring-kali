require 'cairo'
require 'cairo_xlib'

function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_horizontal_bar(cr, x, y, width, height, value, max_value, colour, alpha)
    local percent = math.min(value / max_value, 1.0)
    local bar_width = width * percent

    -- Fond de la barre
    cairo_rectangle(cr, x, y, width, height)
    cairo_set_source_rgba(cr, 0.1, 0.1, 0.1, 0.6)
    cairo_fill(cr)

    -- Marqueurs de repères (10%, 25%, 50%, 75%)
    local markers = {0.1, 0.25, 0.5, 0.75}
    for _, marker in ipairs(markers) do
        local marker_x = x + (width * marker)
        cairo_move_to(cr, marker_x, y)
        cairo_line_to(cr, marker_x, y + height)
        cairo_set_source_rgba(cr, 0.3, 0.3, 0.3, 0.5)
        cairo_set_line_width(cr, 0.5)
        cairo_stroke(cr)
    end

    -- Barre de progression avec couleurs GRISES progressives
    if percent > 0 then
        if bar_width < 2 then bar_width = 2 end

        -- Gris progressif : plus le pourcentage est élevé, plus le gris est clair/foncé
        local r, g, b
        if percent > 0.7 then
            -- Gris très clair pour activité élevée
            r, g, b = 0.85, 0.85, 0.85
        elseif percent > 0.4 then
            -- Gris moyen pour activité moyenne
            r, g, b = 0.6, 0.6, 0.6
        else
            -- Gris foncé pour faible activité
            r, g, b = 0.35, 0.35, 0.35
        end

        cairo_rectangle(cr, x, y, bar_width, height)
        cairo_set_source_rgba(cr, r, g, b, alpha)
        cairo_fill(cr)
    end

    -- Bordure
    cairo_rectangle(cr, x, y, width, height)
    cairo_set_source_rgba(cr, 0.4, 0.4, 0.4, 0.5)
    cairo_set_line_width(cr, 0.5)
    cairo_stroke(cr)
end

function conky_main()
    if conky_window == nil then 
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
                                         conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    -- Récupérer toutes les valeurs avec ss
    local total_conn = tonumber(conky_parse('${exec ss -tn state established | tail -n +2 | wc -l}')) or 0
    local ssh_conn = tonumber(conky_parse('${exec ss -tn state established | grep ":22" | wc -l}')) or 0
    local http_conn = tonumber(conky_parse('${exec ss -tn state established | grep ":80" | wc -l}')) or 0
    local https_conn = tonumber(conky_parse('${exec ss -tn state established | grep ":443" | wc -l}')) or 0
    local downspeed = tonumber(conky_parse('${downspeedf wlan0}')) or tonumber(conky_parse('${downspeedf eth0}')) or 0
    local upspeed = tonumber(conky_parse('${upspeedf wlan0}')) or tonumber(conky_parse('${upspeedf eth0}')) or 0
    local arp_count = tonumber(conky_parse('${execpi 10 ip neigh show 2>/dev/null | grep -v "INCOMPLETE" | grep -c "^"}')) or 0
    local ssh_failed = tonumber(conky_parse('${execpi 300 grep "Failed password" /var/log/auth.log 2>/dev/null | tail -50 | wc -l}')) or 0

    -- Compter les ports TCP et UDP en écoute
    local tcp_listen = tonumber(conky_parse('${exec ss -tln 2>/dev/null | tail -n +2 | wc -l}')) or 0
    local udp_listen = tonumber(conky_parse('${exec ss -uln 2>/dev/null | tail -n +2 | wc -l}')) or 0
    local listening_ports = tcp_listen + udp_listen

    -- Convertir les valeurs avec multiplicateurs
    local conn_value = math.min(total_conn * 2, 100)
    local ssh_value = math.min(ssh_conn * 10, 50)
    local http_value = math.min(http_conn * 2, 50)
    local https_value = math.min(https_conn * 2, 50)
    local down_percent = math.min(downspeed / 10240 * 100, 100)
    local up_percent = math.min(upspeed / 10240 * 100, 100)
    local arp_value = math.min(arp_count * 20, 50)
    local ssh_failed_value = math.min(ssh_failed * 5, 50)
    local listening_value = math.min(listening_ports * 2, 50)  -- Multiplicateur plus bas car UDP 8

    -- Paramètres communs
    local bar_width = 120
    local bar_height = 6

    -- Position X pour les barres de la colonne 1 (connexions)
    local bar_x_col1 = 12

    -- Position X pour les barres de bande passante
    local bar_x_bandwidth = 150

    -- Position X pour les barres de la colonne sécurité
    local bar_x_security = 300

    -- Dessiner les barres de la colonne 1
    draw_horizontal_bar(cr, bar_x_col1, 59, bar_width, bar_height, conn_value, 100, nil, 0.9)
    draw_horizontal_bar(cr, bar_x_col1, 80, bar_width, bar_height, ssh_value, 50, nil, 0.9)
    draw_horizontal_bar(cr, bar_x_col1, 100, bar_width, bar_height, http_value, 50, nil, 0.9)
    draw_horizontal_bar(cr, bar_x_col1, 122, bar_width, bar_height, https_value, 50, nil, 0.9)

    -- Dessiner les barres de bande passante
    draw_horizontal_bar(cr, bar_x_bandwidth, 72, bar_width, bar_height, down_percent, 100, nil, 0.9)
    draw_horizontal_bar(cr, bar_x_bandwidth, 96, bar_width, bar_height, up_percent, 100, nil, 0.9)

    -- Dessiner les barres de la colonne sécurité
    draw_horizontal_bar(cr, bar_x_security, 56, bar_width, bar_height, arp_value, 50, nil, 0.9)
    draw_horizontal_bar(cr, bar_x_security, 96, bar_width, bar_height, ssh_failed_value, 50, nil, 0.9)
    draw_horizontal_bar(cr, bar_x_security, 148, bar_width, bar_height, listening_value, 50, nil, 0.9)

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

require 'cairo'
require 'cairo_xlib'

-- Éviter les erreurs de calcul au démarrage
local function safe_tonumber(str)
    local num = tonumber(str)
    return num or 0
end

-- Fonction de copie de table (remplace table.copy)
local function table_copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

--------------------------------------------------------------------------------
--                                                                    gauge DATA
gauge = {
{
    name='cpu',                    arg='cpu0',                  max_value=100,
    x=185,                         y=210,
    graph_radius=24,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=1.8,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0x444444,      graph_fg_alpha=0.9,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=37,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=1,        graduation_mark_thickness=1,
    graduation_unit_angle=18,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='CPU1',
    caption_weight=1,              caption_size=7.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='cpu',                    arg='cpu1',                  max_value=100,
    x=185,                         y=210,
    graph_radius=16,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=1.8,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.7,
    hand_fg_colour=0xFFFFFF,       hand_fg_alpha=1.0,
    txt_radius=7,
    txt_weight=0,                  txt_size=7.0,
    txt_fg_colour=0xFFFFFF,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=1,        graduation_mark_thickness=1,
    graduation_unit_angle=18,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.8,
    caption='CPU2',
    caption_weight=1,              caption_size=7.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='memperc',                arg='',                      max_value=100,
    x=185,                         y=300,
    graph_radius=24,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=1.8,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0x444444,      graph_fg_alpha=0.9,
    hand_fg_colour=0x444444,       hand_fg_alpha=1.0,
    txt_radius=37,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=1,        graduation_mark_thickness=1,
    graduation_unit_angle=18,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.8,
    caption='RAM',
    caption_weight=1,              caption_size=7.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='fs_used_perc',           arg='/',                     max_value=100,
    x=185,                         y=393,
    graph_radius=24,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=1.8,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0x444444,      graph_fg_alpha=0.9,
    hand_fg_colour=0x444444,       hand_fg_alpha=1.0,
    txt_radius=37,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=1,        graduation_mark_thickness=1,
    graduation_unit_angle=18,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.9,
    caption='ROOT',
    caption_weight=1,              caption_size=7.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='fs_used_perc',           arg='/home',                 max_value=100,
    x=185,                         y=393,
    graph_radius=16,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=1.8,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.7,
    hand_fg_colour=0xFFFFFF,       hand_fg_alpha=1.0,
    txt_radius=7,
    txt_weight=0,                  txt_size=7.0,
    txt_fg_colour=0xFFFFFF,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=1,        graduation_mark_thickness=1,
    graduation_unit_angle=18,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='HOME',
    caption_weight=1,              caption_size=7.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
}

-------------------------------------------------------------------------------
--                                                                 rgb_to_r_g_b
function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

-------------------------------------------------------------------------------
--                                                            angle_to_position
function angle_to_position(start_angle, current_angle)
    local pos = current_angle + start_angle
    return ( ( pos * (2 * math.pi / 360) ) - (math.pi / 2) )
end

-------------------------------------------------------------------------------
--                                                Fonctions de dessin Cairo manquantes

-- Dessiner une ellipse (remplace cairo_ellipse)
function draw_ellipse(cr, cx, cy, rx, ry)
    local steps = 50
    local angle_step = 2 * math.pi / steps

    cairo_move_to(cr, cx + rx, cy)
    for i = 1, steps do
        local angle = i * angle_step
        local x = cx + rx * math.cos(angle)
        local y = cy + ry * math.sin(angle)
        cairo_line_to(cr, x, y)
    end
    cairo_close_path(cr)
end

-- Dessiner une ellipse partielle
function draw_ellipse_partial(cr, cx, cy, rx, ry, start_angle, end_angle)
    local steps = 50
    local angle_step = (end_angle - start_angle) / steps

    cairo_move_to(cr, cx + rx * math.cos(start_angle), cy + ry * math.sin(start_angle))
    for i = 1, steps do
        local angle = start_angle + i * angle_step
        local x = cx + rx * math.cos(angle)
        local y = cy + ry * math.sin(angle)
        cairo_line_to(cr, x, y)
    end
    cairo_close_path(cr)
end

-------------------------------------------------------------------------------
--                                STYLES DE BARRES DE PROGRESSION AVEC GRADUATIONS

-- STYLE 1 : Règle (graduations fines et régulières)
function draw_progress_rule(cr, x, y, width, height, val, fg_colour, fg_alpha, max_value)
    local bar_width = val * (width - 10)

    -- Remplissage avec transparence variable
    local alpha = fg_alpha
    if val >= 0.28 then
        alpha = alpha * 0.4  -- Plus transparent quand plein
    end

    cairo_rectangle(cr, x - width/2 + 5, y - height/2 + 5, bar_width, height - 10)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
    cairo_fill(cr)

    -- Graduations
    local num_graduations = 10
    for i = 1, num_graduations do
        local grad_x = x - width/2 + 5 + (i / num_graduations) * (width - 10)
        if grad_x <= x - width/2 + 5 + bar_width then
            cairo_move_to(cr, grad_x, y - height/2 + 8)
            cairo_line_to(cr, grad_x, y + height/2 - 8)
            cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
            cairo_set_line_width(cr, 0.5)
            cairo_stroke(cr)
        end
    end
end

-- STYLE 2 : Piano (blocs séparés)
function draw_progress_piano(cr, x, y, width, height, val, fg_colour, fg_alpha, max_value)
    local num_blocs = 20
    local bloc_width = (width - 10) / num_blocs
    local active_blocs = math.floor(val * num_blocs)

    local alpha = fg_alpha
    if val >= 0.28 then
        alpha = alpha * 0.4
    end

    for i = 0, num_blocs - 1 do
        local bloc_x = x - width/2 + 5 + i * bloc_width
        local is_active = i < active_blocs
        
        if is_active then
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
        else
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.2))
        end

        cairo_rectangle(cr, bloc_x, y - height/2 + 5, bloc_width - 2, height - 10)
        cairo_fill(cr)
    end
end

-- STYLE 3 : Pointillés
function draw_progress_dots(cr, x, y, width, height, val, fg_colour, fg_alpha, max_value)
    local num_dots = 20
    local dot_spacing = (width - 10) / num_dots
    local dot_radius = 3
    local active_dots = math.floor(val * num_dots)

    local alpha = fg_alpha
    if val >= 0.28 then
        alpha = alpha * 0.4
    end

    for i = 0, num_dots - 1 do
        local dot_x = x - width/2 + 5 + i * dot_spacing + dot_spacing/2
        local is_active = i < active_dots

        if is_active then
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
        else
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.15))
        end
        
        cairo_arc(cr, dot_x, y, dot_radius, 0, 2 * math.pi)
        cairo_fill(cr)
    end
end

-- STYLE 4 : Tirets
function draw_progress_dashes(cr, x, y, width, height, val, fg_colour, fg_alpha, max_value)
    local num_dashes = 15
    local dash_spacing = (width - 10) / num_dashes
    local active_dashes = math.floor(val * num_dashes)

    local alpha = fg_alpha
    if val >= 0.28 then
        alpha = alpha * 0.4
    end

    for i = 0, num_dashes - 1 do
        local dash_x = x - width/2 + 5 + i * dash_spacing
        local is_active = i < active_dashes

        if is_active then
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
        else
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.15))
        end
        
        cairo_move_to(cr, dash_x, y - height/2 + 5)
        cairo_line_to(cr, dash_x, y + height/2 - 5)
        cairo_set_line_width(cr, 2)
        cairo_stroke(cr)
    end
end

-- STYLE 5 : Créneaux (carrés alternés)
function draw_progress_creneaux(cr, x, y, width, height, val, fg_colour, fg_alpha, max_value)
    local num_creneaux = 10
    local creneau_width = (width - 10) / num_creneaux
    local active_creneaux = math.floor(val * num_creneaux)
    local creneau_height = height - 10

    local alpha = fg_alpha
    if val >= 0.28 then
        alpha = alpha * 0.4
    end

    for i = 0, num_creneaux - 1 do
        local creneau_x = x - width/2 + 5 + i * creneau_width
        local is_active = i < active_creneaux

        if is_active then
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
        else
            cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.15))
        end

        if i % 2 == 0 then
            cairo_rectangle(cr, creneau_x, y - height/2 + 5, creneau_width - 2, creneau_height)
            cairo_fill(cr)
        else
            cairo_rectangle(cr, creneau_x, y - height/2 + 5, creneau_width - 2, creneau_height / 2)
            cairo_fill(cr)
        end
    end
end

-------------------------------------------------------------------------------
--                                                              draw_clock_ring
function draw_clock_ring(cr, data, value)
    local max_value = data['max_value']
    local x, y = data['x'], data['y']
    local graph_radius = data['graph_radius']
    local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
    local graph_unit_angle = data['graph_unit_angle']
    local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
    local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']

    cairo_arc(cr, x, y, graph_radius, 0, 2 * math.pi)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
    cairo_set_line_width(cr, graph_thickness)
    cairo_stroke(cr)

    local val = (value % max_value)
    local i = 1
    while i <= val do
        cairo_arc(cr, x, y, graph_radius, ((graph_unit_angle * i - graph_unit_thickness) * 2 * math.pi / 360) - math.pi/2, (graph_unit_angle * i * 2 * math.pi / 360) - math.pi/2)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
        cairo_stroke(cr)
        i = i + 1
    end
    local angle = (graph_unit_angle * i) - graph_unit_thickness

    local graduation_radius = data['graduation_radius']
    local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
    local graduation_unit_angle = data['graduation_unit_angle']
    local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
    if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
        local nb_graduation = 360 / graduation_unit_angle
        local i = 1
        while i <= nb_graduation do
            cairo_set_line_width(cr, graduation_thickness)
            cairo_arc(cr, x, y, graduation_radius, ((graduation_unit_angle * i - graduation_mark_thickness/2) * 2 * math.pi / 360) - math.pi/2, ((graduation_unit_angle * i + graduation_mark_thickness/2) * 2 * math.pi / 360) - math.pi/2)
            cairo_set_source_rgba(cr, rgb_to_r_g_b(graduation_fg_colour, graduation_fg_alpha))
            cairo_stroke(cr)
            i = i + 1
        end
    end

    local txt_radius = data['txt_radius']
    local txt_weight, txt_size = data['txt_weight'], data['txt_size']
    local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
    local movex = txt_radius * math.cos((angle * 2 * math.pi / 360) - math.pi/2)
    local movey = txt_radius * math.sin((angle * 2 * math.pi / 360) - math.pi/2)
    cairo_select_font_face(cr, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, txt_weight)
    cairo_set_font_size(cr, txt_size)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
    cairo_move_to(cr, x + movex - (txt_size / 2), y + movey + 3)
    -- Afficher l'heure en 24h si hide_text est vrai
    if data['hide_text'] then
        local hour24 = tonumber(conky_parse('${time %H}')) or 0
        cairo_show_text(cr, string.format("%02d", hour24))
    else
        cairo_show_text(cr, value)
    end
    cairo_stroke(cr)
end

-------------------------------------------------------------------------------
--                                                              draw_gauge_ring
function draw_gauge_ring(cr, data, value)
    local max_value = data['max_value']
    local x, y = data['x'], data['y']
    local graph_radius = data['graph_radius']
    local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
    local graph_start_angle = data['graph_start_angle']
    local graph_unit_angle = data['graph_unit_angle']
    local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
    local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']
    local hand_fg_colour, hand_fg_alpha = data['hand_fg_colour'], data['hand_fg_alpha']
    local graph_end_angle = (max_value * graph_unit_angle) % 360

    cairo_arc(cr, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
    cairo_set_source_rgba(cr, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
    cairo_set_line_width(cr, graph_thickness)
    cairo_stroke(cr)

    local val = value % (max_value + 1)
    local start_arc = 0
    local i = 1
    while i <= val do
        start_arc = (graph_unit_angle * i) - graph_unit_thickness
        local stop_arc = (graph_unit_angle * i)
        cairo_arc(cr, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
        cairo_set_source_rgba(cr, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
        cairo_stroke(cr)
        i = i + 1
    end
    local angle = start_arc

    start_arc = (graph_unit_angle * val) - (graph_unit_thickness * 2)
    local stop_arc = (graph_unit_angle * val)
    cairo_arc(cr, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
    cairo_set_source_rgba(cr, rgb_to_r_g_b(hand_fg_colour, hand_fg_alpha))
    cairo_stroke(cr)

    local graduation_radius = data['graduation_radius']
    local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
    local graduation_unit_angle = data['graduation_unit_angle']
    local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
    if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
        local nb_graduation = graph_end_angle / graduation_unit_angle
        local i = 0
        while i < nb_graduation do
            cairo_set_line_width(cr, graduation_thickness)
            start_arc = (graduation_unit_angle * i) - (graduation_mark_thickness / 2)
            stop_arc = (graduation_unit_angle * i) + (graduation_mark_thickness / 2)
            cairo_arc(cr, x, y, graduation_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
            cairo_set_source_rgba(cr, rgb_to_r_g_b(graduation_fg_colour, graduation_fg_alpha))
            cairo_stroke(cr)
            i = i + 1
        end
    end

    local txt_radius = data['txt_radius']
    local txt_weight, txt_size = data['txt_weight'], data['txt_size']
    local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
    local movex = txt_radius * math.cos(angle_to_position(graph_start_angle, angle))
    local movey = txt_radius * math.sin(angle_to_position(graph_start_angle, angle))
    cairo_select_font_face(cr, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, txt_weight)
    cairo_set_font_size(cr, txt_size)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
    cairo_move_to(cr, x + movex - (txt_size / 2), y + movey + 3)
    cairo_show_text(cr, value)
    cairo_stroke(cr)

    local caption = data['caption']
    local caption_weight, caption_size = data['caption_weight'], data['caption_size']
    local caption_fg_colour, caption_fg_alpha = data['caption_fg_colour'], data['caption_fg_alpha']
    cairo_select_font_face(cr, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, caption_weight)
    cairo_set_font_size(cr, caption_size)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))

    if caption == 'CPU1' then
        cairo_move_to(cr, x - 11, y -42)
    elseif caption == 'CPU2' then
        cairo_move_to(cr, x - 11, y - 34)
    elseif caption == 'RAM' then
        cairo_move_to(cr, x - 11, y - 34)
    elseif caption == 'ROOT' then
        cairo_move_to(cr, x - 11, y - 39)
    elseif caption == 'HOME' then
        cairo_move_to(cr, x - 11, y - 33)
    end
    cairo_show_text(cr, caption)
    cairo_stroke(cr)
end

-------------------------------------------------------------------------------
--                                                        draw_clock_ring_rect
-- Fonction pour dessiner un rectangle avec coins arrondis à gauche ET à droite
function draw_rounded_rect_both(cr, x, y, width, height, radius)
    -- x, y = centre du rectangle, width, height = dimensions, radius = rayon des coins arrondis

    local left = x - width/2
    local right = x + width/2
    local top = y - height/2
    local bottom = y + height/2

    -- Commencer le chemin
    cairo_move_to(cr, left + radius, top)

    -- Ligne supérieure jusqu'au coin droit arrondi
    cairo_line_to(cr, right - radius, top)
    -- Coin supérieur droit (arrondi)
    cairo_arc(cr, right - radius, top + radius, radius, -math.pi/2, 0)
    -- Ligne droite côté droit
    cairo_line_to(cr, right, bottom - radius)
    -- Coin inférieur droit (arrondi)
    cairo_arc(cr, right - radius, bottom - radius, radius, 0, math.pi/2)
    -- Ligne inférieure
    cairo_line_to(cr, left + radius, bottom)
    -- Coin inférieur gauche (arrondi)
    cairo_arc(cr, left + radius, bottom - radius, radius, math.pi/2, math.pi)
    -- Ligne gauche
    cairo_line_to(cr, left, top + radius)
    -- Coin supérieur gauche (arrondi)
    cairo_arc(cr, left + radius, top + radius, radius, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
end

function draw_clock_ring_rect(cr, data, value, style)
    local max_value = data['max_value']
    local x, y = data['x'], data['y']
    local width = data['width'] or 80
    local height = data['height'] or 80
    local thickness = data['graph_thickness'] or 3
    local fg_colour = data['graph_fg_colour'] or 0x444444
    local fg_alpha = data['graph_fg_alpha'] or 0.9
    local bg_colour = data['graph_bg_colour'] or 0xffffff
    local bg_alpha = data['graph_bg_alpha'] or 0.1
    local corner_radius = data['corner_radius'] or 5

    -- Ombre portée avec coins arrondis
    draw_rounded_rect_both(cr, x + 2, y + 2, width, height, corner_radius)
    cairo_set_source_rgba(cr, 0, 0, 0, 0.2)
    cairo_set_line_width(cr, thickness)
    cairo_stroke(cr)

    -- Arrière-plan avec coins arrondis
    draw_rounded_rect_both(cr, x, y, width, height, corner_radius)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bg_colour, bg_alpha))
    cairo_set_line_width(cr, thickness)
    cairo_stroke(cr)

    -- Valeur de progression
    local val = (value % max_value) / max_value

    -- DÉCALER LA BARRE POUR ÉVITER LES COINS ARRONDIS
    local offset = corner_radius + 2  -- Décallage pour éviter les coins arrondis
    local bar_width = val * (width - offset * 2 - 10)  -- Largeur réduite

    -- Choisir le style de barre (modifié pour utiliser le décalage)
    if style == "rule" then
        -- Barre décalée
        local alpha = fg_alpha
        if val >= 0.28 then
            alpha = alpha * 0.4
        end
        cairo_rectangle(cr, x - width/2 + offset + 5, y - height/2 + 5, bar_width, height - 10)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
        cairo_fill(cr)

        -- Graduations décalées
        local num_graduations = 10
        for i = 1, num_graduations do
            local grad_x = x - width/2 + offset + 5 + (i / num_graduations) * (width - offset * 2 - 10)
            if grad_x <= x - width/2 + offset + 5 + bar_width then
                cairo_move_to(cr, grad_x, y - height/2 + 8)
                cairo_line_to(cr, grad_x, y + height/2 - 8)
                cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
                cairo_set_line_width(cr, 0.5)
                cairo_stroke(cr)
            end
        end
    elseif style == "piano" then
        local num_blocs = 20
        local bloc_width = (width - offset * 2 - 10) / num_blocs
        local active_blocs = math.floor(val * num_blocs)

        local alpha = fg_alpha
        if val >= 0.28 then
            alpha = alpha * 0.4
        end

        for i = 0, num_blocs - 1 do
            local bloc_x = x - width/2 + offset + 5 + i * bloc_width
            local is_active = i < active_blocs

            if is_active then
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
            else
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.2))
            end

            cairo_rectangle(cr, bloc_x, y - height/2 + 5, bloc_width - 2, height - 10)
            cairo_fill(cr)
        end
    elseif style == "dots" then
        local num_dots = 20
        local dot_spacing = (width - offset * 2 - 10) / num_dots
        local dot_radius = 3
        local active_dots = math.floor(val * num_dots)

        local alpha = fg_alpha
        if val >= 0.28 then
            alpha = alpha * 0.4
        end

        for i = 0, num_dots - 1 do
            local dot_x = x - width/2 + offset + 5 + i * dot_spacing + dot_spacing/2
            local is_active = i < active_dots

            if is_active then
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
            else
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.15))
            end

            cairo_arc(cr, dot_x, y, dot_radius, 0, 2 * math.pi)
            cairo_fill(cr)
        end
    elseif style == "dashes" then
        local num_dashes = 15
        local dash_spacing = (width - offset * 2 - 10) / num_dashes
        local active_dashes = math.floor(val * num_dashes)

        local alpha = fg_alpha
        if val >= 0.28 then
            alpha = alpha * 0.4
        end

        for i = 0, num_dashes - 1 do
            local dash_x = x - width/2 + offset + 5 + i * dash_spacing
            local is_active = i < active_dashes

            if is_active then
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
            else
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.15))
            end

            cairo_move_to(cr, dash_x, y - height/2 + 5)
            cairo_line_to(cr, dash_x, y + height/2 - 5)
            cairo_set_line_width(cr, 2)
            cairo_stroke(cr)
        end
    elseif style == "creneaux" then
        local num_creneaux = 10
        local creneau_width = (width - offset * 2 - 10) / num_creneaux
        local active_creneaux = math.floor(val * num_creneaux)
        local creneau_height = height - 10

        local alpha = fg_alpha
        if val >= 0.28 then
            alpha = alpha * 0.4
        end

        for i = 0, num_creneaux - 1 do
            local creneau_x = x - width/2 + offset + 5 + i * creneau_width
            local is_active = i < active_creneaux

            if is_active then
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
            else
                cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha * 0.15))
            end

            if i % 2 == 0 then
                cairo_rectangle(cr, creneau_x, y - height/2 + 5, creneau_width - 2, creneau_height)
                cairo_fill(cr)
            else
                cairo_rectangle(cr, creneau_x, y - height/2 + 5, creneau_width - 2, creneau_height / 2)
                cairo_fill(cr)
            end
        end
    else
        -- Style par défaut (barre décalée)
        local alpha = fg_alpha
        if val >= 0.28 then
            alpha = alpha * 0.4
        end
        cairo_rectangle(cr, x - width/2 + offset + 5, y - height/2 + 5, bar_width, height - 10)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(fg_colour, alpha))
        cairo_fill(cr)
    end
    
    -- Redessiner le contour par-dessus pour masquer les bords
    draw_rounded_rect_both(cr, x, y, width, height, corner_radius)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bg_colour, bg_alpha))
    cairo_set_line_width(cr, thickness)
    cairo_stroke(cr)
end

-------------------------------------------------------------------------------
--                                                        draw_clock_ring_infinity
function draw_clock_ring_infinity(cr, data, value)
    local max_value = data['max_value']
    local x, y = data['x'], data['y']
    local size = data['size'] or 40
    local thickness = data['graph_thickness'] or 2

    -- Effet de lueur (glow) autour de l'infini
    cairo_set_source_rgba(cr, rgb_to_r_g_b(data['graph_fg_colour'] or 0x444444, 0.3))
    cairo_set_line_width(cr, thickness * 3)
    for i = 0, 100 do
        local t = i / 100 * 2 * math.pi
        local px = x + size * math.cos(t) / (1 + math.sin(t) * math.sin(t))
        local py = y + size * math.sin(t) * math.cos(t) / (1 + math.sin(t) * math.sin(t))
        if i == 0 then
            cairo_move_to(cr, px, py)
        else
            cairo_line_to(cr, px, py)
        end
    end
    cairo_stroke(cr)

    -- Arrière-plan (symbole infini complet)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(data['graph_bg_colour'] or 0xffffff, data['graph_bg_alpha'] or 0.1))
    cairo_set_line_width(cr, thickness)

    local steps = 100
    local start_t = 0
    local end_t = 2 * math.pi

    -- Dessiner le contour complet
    for i = 0, steps do
        local t = i / steps * (end_t - start_t) + start_t
        local px = x + size * math.cos(t) / (1 + math.sin(t) * math.sin(t))
        local py = y + size * math.sin(t) * math.cos(t) / (1 + math.sin(t) * math.sin(t))

        if i == 0 then
            cairo_move_to(cr, px, py)
        else
            cairo_line_to(cr, px, py)
        end
    end
    cairo_stroke(cr)

    -- Segment actif (partie colorée) avec épaisseur renforcée
    local val = (value % max_value) / max_value
    local active_steps = math.floor(val * steps)

    if active_steps > 0 then
        -- Couleur plus vive pour la partie active
        cairo_set_source_rgba(cr, rgb_to_r_g_b(data['graph_fg_colour'] or 0x444444, data['graph_fg_alpha'] or 0.9))
        cairo_set_line_width(cr, thickness + 2)  -- Épaisseur renforcée

        for i = 0, active_steps do
            local t = i / steps * (end_t - start_t) + start_t
            local px = x + size * math.cos(t) / (1 + math.sin(t) * math.sin(t))
            local py = y + size * math.sin(t) * math.cos(t) / (1 + math.sin(t) * math.sin(t))

            if i == 0 then
                cairo_move_to(cr, px, py)
            else
                cairo_line_to(cr, px, py)
            end
        end
        cairo_stroke(cr)
    end
end

-------------------------------------------------------------------------------
--                                                                         MAIN
function conky_main()
    if conky_window == nil then 
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    local updates_str = conky_parse('${updates}')
    local update_num = tonumber(updates_str) or 0

    if update_num > 1 then
        -- Récupérer les valeurs pour les jauges (indépendantes de l'horloge)
        for i in pairs(gauge) do
            local str = string.format('${%s %s}', gauge[i]['name'], gauge[i]['arg'])
            local value = safe_tonumber(conky_parse(str))
            draw_gauge_ring(cr, gauge[i], value)
        end

        -- Récupérer les valeurs pour l'horloge
        local hour = safe_tonumber(conky_parse('${time %H}'))
        local minute = safe_tonumber(conky_parse('${time %M}'))
        local second = safe_tonumber(conky_parse('${time %S}'))

        -- CHOISIR LE STYLE DE BARRE ICI :
        local bar_style = "default"  -- "rule", "piano", "dots", "dashes", "creneaux", "default"

        -- COULEURS POUR LES INFINIS
        local infinity_h_colour = 0x8899AA  -- Bleu acier
        local infinity_m_colour = 0x88CCDD  -- Bleu glacier
        local infinity_s_colour = 0xFF4422  -- Orange/rouge

        -- CONFIGURATION DES RECTANGLES AVEC COINS ARRONDIS UNIQUEMENT POUR LE CONTOUR
				local rect_h = {
						max_value=24, 
						x=225, 
						y=60, 
						width=120, 
						height=30, 
						graph_thickness=1, 
						graph_bg_colour=0xffffff, 
						graph_bg_alpha=0.1, 
						graph_fg_colour=0x444444, 
						graph_fg_alpha=0.9,
						corner_radius=15  -- AJOUTEZ CE PARAMÈTRE
				}

				local rect_m = {
						max_value=60, 
						x=225, 
						y=95, 
						width=120, 
						height=30, 
						graph_thickness=1, 
						graph_bg_colour=0xffffff, 
						graph_bg_alpha=0.1, 
						graph_fg_colour=0xFFFFFF, 
						graph_fg_alpha=0.8,
						corner_radius=15  -- AJOUTEZ CE PARAMÈTRE
				}

				local rect_s = {
						max_value=60, 
						x=225, 
						y=130, 
						width=120, 
						height=30, 
						graph_thickness=1, 
						graph_bg_colour=0xffffff, 
						graph_bg_alpha=0.1, 
						graph_fg_colour=0xEF5A29, 
						graph_fg_alpha=0.8,
						corner_radius=15  -- AJOUTEZ CE PARAMÈTRE
				}

        -- CONFIGURATION DES INFINIS
        local infinity_h = {max_value=24, x=225, y=60, size=20, graph_thickness=0.5, graph_bg_colour=0xffffff, graph_bg_alpha=0.1, graph_fg_colour=infinity_h_colour, graph_fg_alpha=0.9}
        local infinity_m = {max_value=60, x=225, y=95, size=20, graph_thickness=0.5, graph_bg_colour=0xffffff, graph_bg_alpha=0.1, graph_fg_colour=infinity_m_colour, graph_fg_alpha=0.8}
        local infinity_s = {max_value=60, x=225, y=130, size=20, graph_thickness=0.5, graph_bg_colour=0xffffff, graph_bg_alpha=0.1, graph_fg_colour=infinity_s_colour, graph_fg_alpha=0.8}

        -- ORDRE DE DESSIN : Rectangles d'abord, Infinis par-dessus
        draw_clock_ring_rect(cr, rect_h, hour, bar_style)
        draw_clock_ring_rect(cr, rect_m, minute, bar_style)
        draw_clock_ring_rect(cr, rect_s, second, bar_style)

        draw_clock_ring_infinity(cr, infinity_h, hour)
        draw_clock_ring_infinity(cr, infinity_m, minute)
        draw_clock_ring_infinity(cr, infinity_s, second)

        -- Contour supplémentaire des rectangles avec coins arrondis des deux côtés
				draw_rounded_rect_both(cr, rect_h.x, rect_h.y, rect_h.width, rect_h.height, rect_h.corner_radius)
				cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
				cairo_set_line_width(cr, 1)
				cairo_stroke(cr)

				draw_rounded_rect_both(cr, rect_m.x, rect_m.y, rect_m.width, rect_m.height, rect_m.corner_radius)
				cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
				cairo_set_line_width(cr, 1)
				cairo_stroke(cr)

				draw_rounded_rect_both(cr, rect_s.x, rect_s.y, rect_s.width, rect_s.height, rect_s.corner_radius)
				cairo_set_source_rgba(cr, 1, 1, 1, 0.3)
				cairo_set_line_width(cr, 1)
				cairo_stroke(cr)

        -- AFFICHER LES VALEURS NUMÉRIQUES À DROITE
        cairo_select_font_face(cr, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, 0)
        cairo_set_font_size(cr, 8)

        -- Heures (avec ombre)
        cairo_set_source_rgba(cr, 0, 0, 0, 0.3)
        cairo_move_to(cr, 197, 57)
        cairo_show_text(cr, string.format("%02d", hour))
        cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 0.9)
        cairo_move_to(cr, 172, 63)
        cairo_show_text(cr, string.format("%02d", hour))

        -- Minutes (avec ombre)
        cairo_set_source_rgba(cr, 0, 0, 0, 0.3)
        cairo_move_to(cr, 197, 92)
        cairo_show_text(cr, string.format("%02d", minute))
        cairo_set_source_rgba(cr, 0.7, 0.7, 0.7, 0.9)
        cairo_move_to(cr, 172, 98)
        cairo_show_text(cr, string.format("%02d", minute))

        -- Secondes (avec ombre)
        cairo_set_source_rgba(cr, 0, 0, 0, 0.3)
        cairo_move_to(cr, 197, 127)
        cairo_show_text(cr, string.format("%02d", second))
        cairo_set_source_rgba(cr, 0.9, 0.35, 0.16, 0.9)
        cairo_move_to(cr, 172, 133)
        cairo_show_text(cr, string.format("%02d", second))
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end

import math
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUTPUT_DIR = "/home/venkatengineer/aetheris-mobile/assets"
WP_DIR = os.path.join(OUTPUT_DIR, "wallpapers")
ICON_DIR = os.path.join(OUTPUT_DIR, "icons")
FONT_DIR = os.path.join(OUTPUT_DIR, "fonts")

os.makedirs(WP_DIR, exist_ok=True)
os.makedirs(ICON_DIR, exist_ok=True)

FONT_ORBITRON = os.path.join(FONT_DIR, "Orbitron.ttf")
FONT_RAJDHANI = os.path.join(FONT_DIR, "Rajdhani-Bold.ttf")
FONT_MONO = os.path.join(FONT_DIR, "JetBrainsMono-Bold.ttf")

# Design Tokens
COLOR_BG = (3, 6, 10)
COLOR_EMERALD = (0, 255, 102)
COLOR_EMERALD_DIM = (0, 255, 102, 35)
COLOR_CYAN = (0, 240, 255)
COLOR_CYAN_DIM = (0, 240, 255, 30)
COLOR_WHITE = (223, 248, 246)
COLOR_MUTED = (93, 122, 140)

def draw_hud_brackets(draw, x, y, w, h, size=30, color=COLOR_EMERALD, width=2):
    # Top-Left
    draw.line([(x, y + size), (x, y), (x + size, y)], fill=color, width=width)
    # Top-Right
    draw.line([(x + w - size, y), (x + w, y), (x + w, y + size)], fill=color, width=width)
    # Bottom-Left
    draw.line([(x, y + h - size), (x, y + h), (x + size, y + h)], fill=color, width=width)
    # Bottom-Right
    draw.line([(x + w - size, y + h), (x + w, y + h), (x + w, y + h - size)], fill=color, width=width)

def draw_hex_glyph(draw, cx, cy, radius, color=COLOR_EMERALD, width=2, fill=None):
    points = []
    for i in range(6):
        angle = math.radians(60 * i - 30)
        px = cx + radius * math.cos(angle)
        py = cy + radius * math.sin(angle)
        points.append((px, py))
    if fill:
        draw.polygon(points, fill=fill)
    draw.polygon(points, outline=color, width=width)

def create_home_wallpaper():
    width, height = 2520, 2800
    img = Image.new("RGBA", (width, height), COLOR_BG)
    draw = ImageDraw.Draw(img)

    # Subtle background gradient
    for y in range(0, height, 4):
        ratio = y / height
        # Slightly elevate luminosity towards upper-middle
        alpha = int(18 * math.sin(ratio * math.pi))
        draw.line([(0, y), (width, y)], fill=(0, 240, 255, alpha), width=4)

    # Fine Grid Overlay
    grid_spacing = 70
    for x in range(0, width, grid_spacing):
        opacity = 18 if (x % (grid_spacing * 4) == 0) else 6
        draw.line([(x, 0), (x, height)], fill=(0, 255, 136, opacity), width=1)
    for y in range(0, height, grid_spacing):
        opacity = 18 if (y % (grid_spacing * 4) == 0) else 6
        draw.line([(0, y), (width, y)], fill=(0, 240, 255, opacity), width=1)

    # Upper Canopy Framing
    cx = width // 2
    f_orbitron_lg = ImageFont.truetype(FONT_ORBITRON, 34)
    f_mono_sm = ImageFont.truetype(FONT_MONO, 18)
    f_rajdhani_md = ImageFont.truetype(FONT_RAJDHANI, 26)

    # Top Header Banner
    draw.line([(140, 180), (width - 140, 180)], fill=(0, 255, 102, 80), width=2)
    draw.line([(140, 184), (width - 140, 184)], fill=(0, 240, 255, 40), width=1)
    draw.text((cx, 150), "⟦ A E T H E R I S   O S   M O B I L E ⟧", fill=COLOR_WHITE, font=f_orbitron_lg, anchor="mm")
    draw.text((cx, 215), "VOS 7.0 // SNAPDRAGON 7 GEN 3 // ARCH LINUX BRIDGE", fill=COLOR_EMERALD, font=f_mono_sm, anchor="mm")

    # Corner flight deck telemetry
    draw_hud_brackets(draw, 100, 120, width - 200, height - 240, size=80, color=COLOR_CYAN, width=3)
    draw.text((120, 250), "LAT: 13.0827°N // LON: 80.2707°E", fill=(93, 122, 140, 180), font=f_mono_sm)
    draw.text((120, 275), "CHENNAI SECTOR // MATRIX NOMINAL", fill=(93, 122, 140, 180), font=f_mono_sm)
    draw.text((width - 120, 250), "REFRESH: 120 HZ // AMOLED 1.5K", fill=(0, 255, 102, 180), font=f_mono_sm, anchor="ra")
    draw.text((width - 120, 275), "OPTICAL SECURITY: ACTIVE", fill=(0, 240, 255, 180), font=f_mono_sm, anchor="ra")

    # Central Orbital Telemetry Matrix (Positioned gracefully behind widget layer)
    cy = 1050
    # Concentric orbital rings
    draw.ellipse([(cx - 420, cy - 420), (cx + 420, cy + 420)], outline=(0, 240, 255, 35), width=2)
    draw.ellipse([(cx - 320, cy - 320), (cx + 320, cy + 320)], outline=(0, 255, 102, 45), width=2)
    draw.ellipse([(cx - 200, cy - 200), (cx + 200, cy + 200)], outline=(0, 240, 255, 60), width=3)
    draw.ellipse([(cx - 120, cy - 120), (cx + 120, cy + 120)], outline=(0, 255, 102, 90), width=2)

    # Dial graduation ticks
    for deg in range(0, 360, 5):
        rad = math.radians(deg)
        r_inner = 310 if deg % 30 == 0 else 315
        r_outer = 320
        p1 = (cx + r_inner * math.cos(rad), cy + r_inner * math.sin(rad))
        p2 = (cx + r_outer * math.cos(rad), cy + r_outer * math.sin(rad))
        col = (0, 255, 102, 140) if deg % 30 == 0 else (0, 240, 255, 50)
        draw.line([p1, p2], fill=col, width=2 if deg % 30 == 0 else 1)

    # Hexagonal Starship Insignia in center
    draw_hex_glyph(draw, cx, cy, 70, color=(0, 255, 102, 220), width=3, fill=(6, 16, 24, 180))
    draw_hex_glyph(draw, cx, cy, 45, color=(0, 240, 255, 200), width=2)
    draw.ellipse([(cx - 10, cy - 10), (cx + 10, cy + 10)], fill=COLOR_EMERALD)

    # Subtle lower chassis lines (above dock area)
    draw.line([(200, 2250), (width - 200, 2250)], fill=(0, 255, 102, 50), width=2)
    draw.line([(cx - 150, 2250), (cx + 150, 2250)], fill=(0, 240, 255, 160), width=4)
    draw.text((cx, 2275), "◈ T E L E M E T R Y   N E X U S ◈", fill=(93, 122, 140, 160), font=f_mono_sm, anchor="mm")

    dest = os.path.join(WP_DIR, "aetheris_home_wallpaper.png")
    img.save(dest, "PNG", optimize=True)
    print(f"Generated: {dest}")

def create_lock_wallpaper():
    width, height = 1260, 2800
    img = Image.new("RGBA", (width, height), COLOR_BG)
    draw = ImageDraw.Draw(img)

    # Subtle ambient gradient
    for y in range(0, height, 4):
        ratio = y / height
        alpha = int(14 * math.sin(ratio * math.pi))
        draw.line([(0, y), (width, y)], fill=(0, 255, 102, alpha), width=4)

    # Fine Grid
    grid_spacing = 60
    for x in range(0, width, grid_spacing):
        opacity = 14 if (x % (grid_spacing * 4) == 0) else 5
        draw.line([(x, 0), (x, height)], fill=(0, 240, 255, opacity), width=1)
    for y in range(0, height, grid_spacing):
        opacity = 14 if (y % (grid_spacing * 4) == 0) else 5
        draw.line([(0, y), (width, y)], fill=(0, 255, 102, opacity), width=1)

    cx = width // 2
    f_orbitron_sm = ImageFont.truetype(FONT_ORBITRON, 20)
    f_mono = ImageFont.truetype(FONT_MONO, 16)
    f_rajdhani_lg = ImageFont.truetype(FONT_RAJDHANI, 32)

    # Lock Screen Top Chrono Framing
    draw_hud_brackets(draw, 80, 220, width - 160, 480, size=50, color=COLOR_CYAN, width=2)
    draw.text((cx, 200), "⟦ SYSTEM LOCK // AETHERIS OS ⟧", fill=COLOR_EMERALD, font=f_orbitron_sm, anchor="mm")
    
    # Mid-screen Aerospace Compass
    cy = 1350
    draw.ellipse([(cx - 260, cy - 260), (cx + 260, cy + 260)], outline=(0, 240, 255, 45), width=2)
    draw.ellipse([(cx - 180, cy - 180), (cx + 180, cy + 180)], outline=(0, 255, 102, 55), width=2)
    draw_hex_glyph(draw, cx, cy, 70, color=(0, 255, 102, 180), width=3, fill=(6, 16, 24, 160))
    draw_hex_glyph(draw, cx, cy, 40, color=(0, 240, 255, 180), width=2)

    # Dial graduation ticks
    for deg in range(0, 360, 10):
        rad = math.radians(deg)
        r_inner = 250 if deg % 30 == 0 else 254
        r_outer = 260
        p1 = (cx + r_inner * math.cos(rad), cy + r_inner * math.sin(rad))
        p2 = (cx + r_outer * math.cos(rad), cy + r_outer * math.sin(rad))
        draw.line([p1, p2], fill=(0, 255, 102, 120) if deg % 30 == 0 else (0, 240, 255, 40), width=1)

    # Bottom biometric sensor target framing
    draw.text((cx, 2280), "OPTICAL SENSOR TARGET", fill=(93, 122, 140, 180), font=f_mono, anchor="mm")
    draw.text((cx, 2310), "BIOMETRIC SECURE ZONE", fill=(0, 255, 102, 160), font=f_mono, anchor="mm")
    draw_hex_glyph(draw, cx, 2430, 65, color=(0, 240, 255, 80), width=2)

    dest = os.path.join(WP_DIR, "aetheris_lock_wallpaper.png")
    img.save(dest, "PNG", optimize=True)
    print(f"Generated: {dest}")

def create_aod_graphic():
    size = 1080
    img = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    cx, cy = size // 2, size // 2
    f_orbitron = ImageFont.truetype(FONT_ORBITRON, 28)
    f_mono = ImageFont.truetype(FONT_MONO, 22)

    # Deep OLED AOD Minimal Rings
    draw.ellipse([(cx - 300, cy - 300), (cx + 300, cy + 300)], outline=(0, 240, 255, 140), width=2)
    draw.ellipse([(cx - 240, cy - 240), (cx + 240, cy + 240)], outline=(0, 255, 102, 120), width=2)
    draw_hex_glyph(draw, cx, cy, 80, color=(0, 255, 102, 220), width=3)
    draw_hex_glyph(draw, cx, cy, 45, color=(0, 240, 255, 200), width=2)

    draw.text((cx, cy - 360), "A E T H E R I S", fill=(223, 248, 246, 220), font=f_orbitron, anchor="mm")
    draw.text((cx, cy + 360), "STANDBY // SECURE", fill=(0, 255, 102, 180), font=f_mono, anchor="mm")

    dest = os.path.join(WP_DIR, "aetheris_aod_graphic.png")
    img.save(dest, "PNG", optimize=True)
    print(f"Generated: {dest}")

def create_aetheris_icons():
    # 20 Canonical icons requested:
    # Phone, Messages, Contacts, Camera, Gallery, Files, Settings, Browser,
    # YouTube, WhatsApp, Instagram, Spotify, GitHub, Terminal, Maps,
    # Calendar, Clock, Calculator, Notes, Play Store
    icons = {
        "phone": "PHONE",
        "messages": "COMMS",
        "contacts": "IDENTITY",
        "camera": "OPTICS",
        "gallery": "VISUALS",
        "files": "STORAGE",
        "settings": "CONFIG",
        "browser": "NEXUS",
        "youtube": "STREAM",
        "whatsapp": "RELAY",
        "instagram": "SPECTRUM",
        "spotify": "AUDIO",
        "github": "QUANTUM",
        "terminal": "CONSOLE",
        "maps": "NAVIGATE",
        "calendar": "CHRONO",
        "clock": "TIME",
        "calculator": "COMPUTE",
        "notes": "BUFFER",
        "playstore": "CORE"
    }

    glyph_drawings = {
        "phone": lambda d, cx, cy: d.polygon([(cx-30, cy+50), (cx-50, cy+30), (cx-30, cy-50), (cx+10, cy-40), (cx-10, cy-10), (cx+10, cy+10), (cx+40, cy-10), (cx+50, cy+30), (cx+30, cy+50)], outline=COLOR_EMERALD, width=8),
        "messages": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-50), (cx+65, cy+35)], radius=14, outline=COLOR_CYAN, width=7), d.polygon([(cx-25, cy+35), (cx-45, cy+65), (cx, cy+35)], fill=COLOR_CYAN)],
        "contacts": lambda d, cx, cy: [d.ellipse([(cx-30, cy-65), (cx+30, cy-5)], outline=COLOR_EMERALD, width=7), d.arc([(cx-55, cy+5), (cx+55, cy+85)], 190, 350, fill=COLOR_CYAN, width=7)],
        "camera": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-40), (cx+65, cy+55)], radius=16, outline=COLOR_CYAN, width=7), d.ellipse([(cx-35, cy-20), (cx+35, cy+50)], outline=COLOR_EMERALD, width=7), d.rectangle([(cx-30, cy-55), (cx+10, cy-40)], outline=COLOR_CYAN, width=6)],
        "gallery": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-55), (cx+65, cy+55)], radius=14, outline=COLOR_EMERALD, width=7), d.polygon([(cx-45, cy+35), (cx-10, cy-10), (cx+15, cy+20), (cx+35, cy-25), (cx+55, cy+35)], outline=COLOR_CYAN, width=6)],
        "files": lambda d, cx, cy: [d.polygon([(cx-65, cy-50), (cx-10, cy-50), (cx+5, cy-30), (cx+65, cy-30), (cx+65, cy+50), (cx-65, cy+50)], outline=COLOR_EMERALD, width=7)],
        "settings": lambda d, cx, cy: [draw_hex_glyph(d, cx, cy, 65, color=COLOR_CYAN, width=7), d.ellipse([(cx-25, cy-25), (cx+25, cy+25)], outline=COLOR_EMERALD, width=7)],
        "browser": lambda d, cx, cy: [d.ellipse([(cx-65, cy-65), (cx+65, cy+65)], outline=COLOR_CYAN, width=7), d.line([(cx-65, cy), (cx+65, cy)], fill=COLOR_EMERALD, width=6), d.ellipse([(cx-30, cy-65), (cx+30, cy+65)], outline=COLOR_EMERALD, width=6)],
        "youtube": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-45), (cx+65, cy+45)], radius=18, outline=COLOR_EMERALD, width=7), d.polygon([(cx-15, cy-25), (cx+25, cy), (cx-15, cy+25)], fill=COLOR_CYAN)],
        "whatsapp": lambda d, cx, cy: [d.ellipse([(cx-65, cy-65), (cx+65, cy+45)], outline=COLOR_EMERALD, width=7), d.polygon([(cx-45, cy+30), (cx-65, cy+65), (cx-20, cy+45)], fill=COLOR_EMERALD), d.line([(cx-25, cy-20), (cx+25, cy+15)], fill=COLOR_CYAN, width=7)],
        "instagram": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-65), (cx+65, cy+65)], radius=28, outline=COLOR_CYAN, width=7), d.ellipse([(cx-32, cy-32), (cx+32, cy+32)], outline=COLOR_EMERALD, width=7), d.ellipse([(cx+32, cy-40), (cx+42, cy-30)], fill=COLOR_EMERALD)],
        "spotify": lambda d, cx, cy: [d.ellipse([(cx-65, cy-65), (cx+65, cy+65)], outline=COLOR_EMERALD, width=7), d.arc([(cx-45, cy-40), (cx+45, cy+10)], 200, 340, fill=COLOR_EMERALD, width=8), d.arc([(cx-38, cy-20), (cx+38, cy+25)], 200, 340, fill=COLOR_CYAN, width=7), d.arc([(cx-32, cy-2), (cx+32, cy+40)], 200, 340, fill=COLOR_CYAN, width=6)],
        "github": lambda d, cx, cy: [d.ellipse([(cx-65, cy-65), (cx+65, cy+65)], outline=COLOR_CYAN, width=7), draw_hex_glyph(d, cx, cy, 38, color=COLOR_EMERALD, width=6)],
        "terminal": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-55), (cx+65, cy+55)], radius=14, outline=COLOR_EMERALD, width=7), d.line([(cx-40, cy-25), (cx-15, cy), (cx-40, cy+25)], fill=COLOR_CYAN, width=7), d.line([(cx-5, cy+25), (cx+35, cy+25)], fill=COLOR_EMERALD, width=7)],
        "maps": lambda d, cx, cy: [d.polygon([(cx, cy-65), (cx+45, cy-25), (cx, cy+65), (cx-45, cy-25)], outline=COLOR_CYAN, width=7), d.ellipse([(cx-15, cy-25), (cx+15, cy+5)], fill=COLOR_EMERALD)],
        "calendar": lambda d, cx, cy: [d.rounded_rectangle([(cx-65, cy-55), (cx+65, cy+55)], radius=14, outline=COLOR_EMERALD, width=7), d.line([(cx-65, cy-20), (cx+65, cy-20)], fill=COLOR_CYAN, width=6), d.line([(cx-35, cy-65), (cx-35, cy-45)], fill=COLOR_CYAN, width=7), d.line([(cx+35, cy-65), (cx+35, cy-45)], fill=COLOR_CYAN, width=7)],
        "clock": lambda d, cx, cy: [d.ellipse([(cx-65, cy-65), (cx+65, cy+65)], outline=COLOR_CYAN, width=7), d.line([(cx, cy), (cx, cy-38)], fill=COLOR_EMERALD, width=7), d.line([(cx, cy), (cx+28, cy)], fill=COLOR_EMERALD, width=7), d.ellipse([(cx-6, cy-6), (cx+6, cy+6)], fill=COLOR_CYAN)],
        "calculator": lambda d, cx, cy: [d.rounded_rectangle([(cx-55, cy-65), (cx+55, cy+65)], radius=16, outline=COLOR_EMERALD, width=7), d.line([(cx-35, cy-40), (cx+35, cy-40)], fill=COLOR_CYAN, width=6), d.line([(cx-30, cy+10), (cx-10, cy+10)], fill=COLOR_CYAN, width=6), d.line([(cx+10, cy+10), (cx+30, cy+10)], fill=COLOR_CYAN, width=6), d.line([(cx-20, cy), (cx-20, cy+20)], fill=COLOR_CYAN, width=6)],
        "notes": lambda d, cx, cy: [d.polygon([(cx-55, cy-65), (cx+20, cy-65), (cx+55, cy-30), (cx+55, cy+65), (cx-55, cy+65)], outline=COLOR_CYAN, width=7), d.line([(cx-35, cy-15), (cx+35, cy-15)], fill=COLOR_EMERALD, width=6), d.line([(cx-35, cy+15), (cx+35, cy+15)], fill=COLOR_EMERALD, width=6), d.line([(cx-35, cy+40), (cx+15, cy+40)], fill=COLOR_EMERALD, width=6)],
        "playstore": lambda d, cx, cy: [d.polygon([(cx-55, cy-65), (cx+55, cy), (cx-55, cy+65)], outline=COLOR_EMERALD, width=8), d.line([(cx-55, cy-65), (cx+20, cy+25)], fill=COLOR_CYAN, width=6), d.line([(cx-55, cy+65), (cx+20, cy-25)], fill=COLOR_CYAN, width=6)]
    }

    size = 256
    cx, cy = size // 2, size // 2
    f_mono = ImageFont.truetype(FONT_MONO, 18)

    for name, label in icons.items():
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

        # Base Biomechanical Housing (Near-black rounded square with bevel border)
        draw.rounded_rectangle([(16, 16), (size-16, size-16)], radius=42, fill=(6, 12, 19, 240), outline=(0, 255, 102, 140), width=3)
        draw.rounded_rectangle([(24, 24), (size-24, size-24)], radius=36, outline=(0, 240, 255, 60), width=2)

        # Corner technical ticks
        draw.line([(28, 28), (44, 28)], fill=COLOR_CYAN, width=3)
        draw.line([(28, 28), (28, 44)], fill=COLOR_CYAN, width=3)
        draw.line([(size-28, size-28), (size-44, size-28)], fill=COLOR_EMERALD, width=3)
        draw.line([(size-28, size-28), (size-28, size-44)], fill=COLOR_EMERALD, width=3)

        # Draw glyph
        if name in glyph_drawings:
            glyph_drawings[name](draw, cx, cy)

        dest = os.path.join(ICON_DIR, f"{name}.png")
        img.save(dest, "PNG", optimize=True)
        print(f"Generated Icon: {dest}")

if __name__ == "__main__":
    create_home_wallpaper()
    create_lock_wallpaper()
    create_aod_graphic()
    create_aetheris_icons()
    print("ALL AETHERIS ASSETS GENERATED SUCCESSFULLY.")

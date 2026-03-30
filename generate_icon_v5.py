#!/usr/bin/env python3
"""
Generate GitaPearls app icon v5
Clean gradient + lotus + pearl + Om
Fixed alpha compositing
"""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math

size = 1024

# Create base with gradient background (RGB, no alpha)
img = Image.new("RGB", (size, size))
draw = ImageDraw.Draw(img)

# Colors
bg_top = (232, 130, 12)  # Saffron #E8820C
bg_bottom = (245, 197, 66)  # Gold #F5C542
pearl_center = (255, 252, 245)
pearl_mid = (255, 235, 200)
pearl_outer = (255, 210, 160)
petal_color = (255, 220, 170)
om_color = (120, 60, 25)

# Draw gradient background
for y in range(size):
    ratio = y / size
    r = int(bg_top[0] * (1 - ratio) + bg_bottom[0] * ratio)
    g = int(bg_top[1] * (1 - ratio) + bg_bottom[1] * ratio)
    b = int(bg_top[2] * (1 - ratio) + bg_bottom[2] * ratio)
    draw.line([(0, y), (size, y)], fill=(r, g, b))

center = size // 2

# Draw soft radial glow (adds to background)
for r in range(300, 0, -5):
    alpha = int(12 * (1 - r / 300))
    c = (255, 240, 200)
    # Blend with existing background
    bbox = [center - r, center - r, center + r, center + r]
    draw.ellipse(bbox, fill=c)


# Draw 8 lotus petals as soft rounded shapes
def draw_petal(cx, cy, angle, length, width, color):
    rad = math.radians(angle)
    tip_x = cx + length * math.cos(rad)
    tip_y = cy + length * math.sin(rad)

    # Draw multiple overlapping circles for soft petal
    for t in range(0, 100, 2):
        ratio = t / 100
        x = cx + (tip_x - cx) * ratio
        y = cy + (tip_y - cy) * ratio
        r = width * (1 - ratio * 0.7)
        draw.ellipse([x - r, y - r, x + r, y + r], fill=color)


for i in range(8):
    angle = i * 45 - 90
    draw_petal(center, center, angle, 120, 35, petal_color)

# Draw inner 6 petals
inner_color = (255, 235, 190)
for i in range(6):
    angle = i * 60 - 90 + 30
    draw_petal(center, center, angle, 85, 28, inner_color)


# Draw glowing pearl
def draw_pearl(cx, cy, radius):
    # Soft outer glow
    for r in range(radius + 30, radius, -1):
        ratio = (r - radius) / 30
        r_val = int(pearl_outer[0] + (255 - pearl_outer[0]) * (1 - ratio) * 0.5)
        g_val = int(pearl_outer[1] + (255 - pearl_outer[1]) * (1 - ratio) * 0.5)
        b_val = int(pearl_outer[2] + (255 - pearl_outer[2]) * (1 - ratio) * 0.5)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_val, g_val, b_val))

    # Pearl body - radial gradient
    for r in range(radius, 0, -1):
        ratio = r / radius
        if ratio < 0.5:
            # Center to mid
            sub_ratio = ratio / 0.5
            r_val = int(pearl_center[0] * (1 - sub_ratio) + pearl_mid[0] * sub_ratio)
            g_val = int(pearl_center[1] * (1 - sub_ratio) + pearl_mid[1] * sub_ratio)
            b_val = int(pearl_center[2] * (1 - sub_ratio) + pearl_mid[2] * sub_ratio)
        else:
            # Mid to outer
            sub_ratio = (ratio - 0.5) / 0.5
            r_val = int(pearl_mid[0] * (1 - sub_ratio) + pearl_outer[0] * sub_ratio)
            g_val = int(pearl_mid[1] * (1 - sub_ratio) + pearl_outer[1] * sub_ratio)
            b_val = int(pearl_mid[2] * (1 - sub_ratio) + pearl_outer[2] * sub_ratio)

        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_val, g_val, b_val))

    # Specular highlight
    hl_x, hl_y = cx - radius * 0.35, cy - radius * 0.3
    for r in range(25, 0, -1):
        val = 255
        draw.ellipse([hl_x - r, hl_y - r, hl_x + r, hl_y + r], fill=(val, val, val))


draw_pearl(center, center, 90)

# Draw Om symbol using available font
try:
    # Try multiple font paths
    font_paths = [
        "/System/Library/Fonts/Supplemental/Devanagari Sangam MN.ttc",
        "/System/Library/Fonts/Devanagari Sangam MN.ttc",
        "/usr/share/fonts/truetype/noto/NotoSansDevanagari-Regular.ttf",
        "/opt/homebrew/share/fonts/truetype/noto/NotoSansDevanagari-Regular.ttf",
    ]

    font = None
    for fp in font_paths:
        try:
            font = ImageFont.truetype(fp, 130)
            break
        except:
            continue

    if font is None:
        # Last resort: try Arial Unicode if available
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 130)
        except:
            font = ImageFont.load_default()

    om_text = "ॐ"
    bbox = draw.textbbox((0, 0), om_text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx, ty = center - tw // 2, center - th // 2 - 8

    # Draw shadow then text
    draw.text((tx + 2, ty + 2), om_text, font=font, fill=(80, 40, 15))
    draw.text((tx, ty), om_text, font=font, fill=om_color)

except Exception as e:
    print(f"Font error: {e}")

# Apply very subtle blur for softness
img = img.filter(ImageFilter.GaussianBlur(radius=0.4))

# Save
img.save("GitaPearls/Assets.xcassets/AppIcon.appiconset/Icon-1024.png", "PNG")
img.save("app-icon-1024-v5.png", "PNG")
print("✅ Icon generated: Icon-1024.png")

#!/usr/bin/env python3
"""
Generate GitaPearls app icon v2
Design: Glowing golden pearl/lotus with Om symbol
Rich saffron/gold gradient background
"""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
import math

# Create 1024x1024 image - FULL SQUARE (iOS adds rounded corners)
size = 1024
img = Image.new("RGBA", (size, size))
draw = ImageDraw.Draw(img)

# Color palette - rich saffron to gold gradient
colors = {
    "bg_top": (232, 130, 12),  # Deep saffron #E8820C
    "bg_bottom": (245, 197, 66),  # Warm gold #F5C542
    "pearl_center": (255, 248, 220),  # Creamy white center
    "pearl_mid": (255, 220, 150),  # Light gold
    "pearl_edge": (255, 180, 100),  # Orange gold
    "om": (139, 69, 19),  # Dark brown for Om
    "glow": (255, 200, 100, 80),  # Soft glow
}

# Draw gradient background (top to bottom)
for y in range(size):
    ratio = y / size
    r = int(colors["bg_top"][0] * (1 - ratio) + colors["bg_bottom"][0] * ratio)
    g = int(colors["bg_top"][1] * (1 - ratio) + colors["bg_bottom"][1] * ratio)
    b = int(colors["bg_top"][2] * (1 - ratio) + colors["bg_bottom"][2] * ratio)
    draw.line([(0, y), (size, y)], fill=(r, g, b))

# Add subtle radial glow from center
center = size // 2
glow_radius = 400

for r in range(glow_radius, 0, -2):
    alpha = int(40 * (1 - r / glow_radius))
    if alpha > 0:
        glow_color = (255, 220, 150, alpha)
        draw.ellipse([center - r, center - r, center + r, center + r], fill=glow_color)


# Draw stylized lotus flower (simplified for small size recognition)
def draw_lotus_petal_simple(draw, cx, cy, angle, length, width, color):
    """Draw a simplified lotus petal as smooth shape"""
    rad = math.radians(angle)

    # Petal tip
    tip_x = cx + length * math.cos(rad)
    tip_y = cy + length * math.sin(rad)

    # Base width points
    perp_rad = rad + math.pi / 2
    base_x1 = cx + width * math.cos(perp_rad)
    base_y1 = cy + width * math.sin(perp_rad)
    base_x2 = cx - width * math.cos(perp_rad)
    base_y2 = cy - width * math.sin(perp_rad)

    # Control points for bezier curve
    ctrl1_x = cx + length * 0.4 * math.cos(rad) + width * 0.8 * math.cos(perp_rad)
    ctrl1_y = cy + length * 0.4 * math.sin(rad) + width * 0.8 * math.sin(perp_rad)
    ctrl2_x = cx + length * 0.4 * math.cos(rad) - width * 0.8 * math.cos(perp_rad)
    ctrl2_y = cy + length * 0.4 * math.sin(rad) - width * 0.8 * math.sin(perp_rad)

    # Draw as smooth polygon approximation
    points = []
    num_segments = 20

    # Left curve: base1 -> ctrl1 -> tip
    for i in range(num_segments // 2):
        t = i / (num_segments // 2)
        # Quadratic bezier
        x = (1 - t) ** 2 * base_x1 + 2 * (1 - t) * t * ctrl1_x + t**2 * tip_x
        y = (1 - t) ** 2 * base_y1 + 2 * (1 - t) * t * ctrl1_y + t**2 * tip_y
        points.append((x, y))

    # Right curve: tip -> ctrl2 -> base2
    for i in range(num_segments // 2):
        t = i / (num_segments // 2)
        # Quadratic bezier
        x = (1 - t) ** 2 * tip_x + 2 * (1 - t) * t * ctrl2_x + t**2 * base_x2
        y = (1 - t) ** 2 * tip_y + 2 * (1 - t) * t * ctrl2_y + t**2 * base_y2
        points.append((x, y))

    # Close the shape
    points.append((base_x1, base_y1))

    draw.polygon(points, fill=color)


# Draw outer ring of 8 lotus petals (subtle, behind the pearl)
num_petals = 8
petal_length = 200
petal_width = 60

for i in range(num_petals):
    angle = i * (360 / num_petals) - 90  # Start from top
    # Gradient colors for petals
    petal_color = (255, 200, 120, 180)  # Semi-transparent gold
    draw_lotus_petal_simple(
        draw, center, center, angle, petal_length, petal_width, petal_color
    )


# Draw glowing central pearl with multiple layers for luminous effect
def draw_glowing_pearl(draw, cx, cy, radius):
    """Draw a luminous pearl with soft glow"""
    # Outer glow layers
    for i, glow_r in enumerate([radius + 80, radius + 50, radius + 25]):
        alpha = 30 - i * 10
        glow_color = (255, 240, 200, alpha)
        draw.ellipse(
            [cx - glow_r, cy - glow_r, cx + glow_r, cy + glow_r], fill=glow_color
        )

    # Pearl body with radial gradient
    for r in range(radius, 0, -1):
        ratio = r / radius
        # Interpolate from center color to edge color
        r_col = int(
            colors["pearl_center"][0] * (1 - ratio) + colors["pearl_edge"][0] * ratio
        )
        g_col = int(
            colors["pearl_center"][1] * (1 - ratio) + colors["pearl_edge"][1] * ratio
        )
        b_col = int(
            colors["pearl_center"][2] * (1 - ratio) + colors["pearl_edge"][2] * ratio
        )
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_col, g_col, b_col))

    # Highlight - bright spot for 3D effect (top-left)
    highlight_x = cx - radius * 0.3
    highlight_y = cy - radius * 0.35
    highlight_radius = radius * 0.25

    for r in range(int(highlight_radius), 0, -1):
        alpha = int(200 * (1 - r / highlight_radius))
        highlight_color = (255, 255, 255, alpha)
        draw.ellipse(
            [highlight_x - r, highlight_y - r, highlight_x + r, highlight_y + r],
            fill=highlight_color,
        )


# Draw the main pearl
pearl_radius = 140
draw_glowing_pearl(draw, center, center, pearl_radius)

# Draw Om symbol embossed on the pearl
# Use a clean, readable font
try:
    om_font = ImageFont.truetype(
        "/System/Library/Fonts/Supplemental/Devanagari Sangam MN.ttc", 140
    )
except:
    try:
        om_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 140)
    except:
        om_font = ImageFont.load_default()

om_text = "ॐ"
bbox = draw.textbbox((0, 0), om_text, font=om_font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

om_x = center - text_width // 2
om_y = center - text_height // 2 - 8  # Slight adjustment for visual center

# Draw Om with subtle shadow for embossed effect
draw.text(
    (om_x + 2, om_y + 2), om_text, font=om_font, fill=(100, 50, 20, 100)
)  # Soft shadow
draw.text((om_x, om_y), om_text, font=om_font, fill=colors["om"])  # Main Om

# Add inner ring of 6 smaller petals (more subtle, for depth)
num_inner_petals = 6
inner_petal_length = 120
inner_petal_width = 40

for i in range(num_inner_petals):
    angle = i * (360 / num_inner_petals) - 90 + 30  # Offset from outer petals
    inner_color = (255, 220, 160, 120)
    draw_lotus_petal_simple(
        draw, center, center, angle, inner_petal_length, inner_petal_width, inner_color
    )

# Apply slight blur for soft glow effect
img = img.filter(ImageFilter.GaussianBlur(radius=0.5))

# Convert to RGB for final output (no transparency for app icons)
final_img = Image.new("RGB", (size, size), (245, 197, 66))
final_img.paste(img, mask=img.split()[3] if img.mode == "RGBA" else None)

# Save the icon
output_path = "GitaPearls/Assets.xcassets/AppIcon.appiconset/Icon-1024.png"
final_img.save(output_path, "PNG", quality=95)
print(f"✅ App icon saved to: {output_path}")

# Also save a copy in the root
final_img.save("app-icon-1024-v2.png", "PNG", quality=95)
print(f"✅ Copy saved to: app-icon-1024-v2.png")

print(f"\nIcon stats: {final_img.size}x{final_img.size}, mode: {final_img.mode}")

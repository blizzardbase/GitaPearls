#!/usr/bin/env python3
"""
Generate GitaPearls app icon
Design: Lotus petals with Om symbol, warm orange/gold tones
"""

from PIL import Image, ImageDraw, ImageFont
import math

# Create 1024x1024 image with transparent background
size = 1024
img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Define warm orange/gold color palette
colors = {
    "background": (255, 248, 240),  # Warm cream
    "center": (255, 140, 66),  # Deep orange
    "petal_inner": (255, 180, 100),  # Light orange
    "petal_outer": (255, 120, 60),  # Darker orange
    "om": (139, 69, 19),  # Dark brown/gold
    "highlight": (255, 220, 150),  # Gold highlight
    "shadow": (200, 100, 50),  # Shadow orange
}

# Fill background with rounded corners (iOS app icon mask)
bg_radius = 230  # iOS icon corner radius proportion
center = size // 2


# Draw background with rounded corners
def draw_rounded_rect(draw, xy, radius, fill):
    x1, y1, x2, y2 = xy
    r = radius
    # Draw main rectangle
    draw.rectangle([x1 + r, y1, x2 - r, y2], fill=fill)
    draw.rectangle([x1, y1 + r, x2, y2 - r], fill=fill)
    # Draw four corners
    draw.ellipse([x1, y1, x1 + r * 2, y1 + r * 2], fill=fill)
    draw.ellipse([x2 - r * 2, y1, x2, y1 + r * 2], fill=fill)
    draw.ellipse([x1, y2 - r * 2, x1 + r * 2, y2], fill=fill)
    draw.ellipse([x2 - r * 2, y2 - r * 2, x2, y2], fill=fill)


draw_rounded_rect(draw, (0, 0, size, size), bg_radius, colors["background"])


# Draw lotus petals
def draw_petal(draw, cx, cy, angle, length, width, color_inner, color_outer):
    """Draw a single lotus petal"""
    # Calculate petal points
    rad = math.radians(angle)

    # Petal tip
    tip_x = cx + length * math.cos(rad)
    tip_y = cy + length * math.sin(rad)

    # Petal base points (perpendicular to angle)
    perp_rad = rad + math.pi / 2
    base_offset = width / 2

    base1_x = cx + base_offset * math.cos(perp_rad)
    base1_y = cy + base_offset * math.sin(perp_rad)
    base2_x = cx - base_offset * math.cos(perp_rad)
    base2_y = cy - base_offset * math.sin(perp_rad)

    # Control points for curve
    ctrl1_x = cx + length * 0.5 * math.cos(rad) + width * 0.3 * math.cos(perp_rad)
    ctrl1_y = cy + length * 0.5 * math.sin(rad) + width * 0.3 * math.sin(perp_rad)
    ctrl2_x = cx + length * 0.5 * math.cos(rad) - width * 0.3 * math.cos(perp_rad)
    ctrl2_y = cy + length * 0.5 * math.sin(rad) - width * 0.3 * math.sin(perp_rad)

    # Draw petal as polygon with gradient effect
    points = [
        (base1_x, base1_y),
        (ctrl1_x, ctrl1_y),
        (tip_x, tip_y),
        (ctrl2_x, ctrl2_y),
        (base2_x, base2_y),
    ]

    # Create gradient effect by drawing multiple layers
    for i, offset in enumerate([(0, 0), (1, 1), (2, 2)]):
        color = color_inner if i < 2 else color_outer
        offset_points = [(p[0] + offset[0], p[1] + offset[1]) for p in points]
        draw.polygon(offset_points, fill=color)

    return tip_x, tip_y


# Draw inner ring of petals (6 petals)
num_inner_petals = 6
inner_radius = 180
petal_length_inner = 140
petal_width_inner = 70

for i in range(num_inner_petals):
    angle = i * (360 / num_inner_petals) - 90  # Start from top
    draw_petal(
        draw,
        center,
        center,
        angle,
        petal_length_inner,
        petal_width_inner,
        colors["petal_inner"],
        colors["petal_outer"],
    )

# Draw outer ring of petals (8 petals, offset)
num_outer_petals = 8
outer_radius = 220
petal_length_outer = 120
petal_width_outer = 60

for i in range(num_outer_petals):
    angle = (
        i * (360 / num_outer_petals) - 90 + (360 / num_outer_petals / 2)
    )  # Offset by half
    # Lighter color for outer ring
    light_petal = (255, 200, 130)
    dark_petal = (255, 150, 80)
    draw_petal(
        draw,
        center,
        center,
        angle,
        petal_length_outer,
        petal_width_outer,
        light_petal,
        dark_petal,
    )


# Draw central pearl/circle with gradient
def draw_gradient_circle(draw, cx, cy, radius, color_center, color_edge):
    """Draw a circle with radial gradient"""
    for r in range(radius, 0, -1):
        # Interpolate color
        ratio = r / radius
        r_col = int(color_center[0] * (1 - ratio) + color_edge[0] * ratio)
        g_col = int(color_center[1] * (1 - ratio) + color_edge[1] * ratio)
        b_col = int(color_center[2] * (1 - ratio) + color_edge[2] * ratio)

        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_col, g_col, b_col))


# Draw central pearl
draw_gradient_circle(draw, center, center, 110, colors["highlight"], colors["center"])

# Draw highlight on pearl (smaller circle for 3D effect)
draw.ellipse(
    [center - 40, center - 50, center + 20, center - 10], fill=(255, 240, 200, 180)
)

# Draw Om symbol in the center
try:
    # Try to use a system font that might have Devanagari support
    om_size = 120
    om_font = ImageFont.truetype(
        "/System/Library/Fonts/Supplemental/Devanagari Sangam MN.ttc", om_size
    )
except:
    try:
        om_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", om_size)
    except:
        om_font = ImageFont.load_default()

# Get text size for centering
om_text = "ॐ"
bbox = draw.textbbox((0, 0), om_text, font=om_font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

om_x = center - text_width // 2
om_y = center - text_height // 2 - 10  # Slight adjustment

# Draw Om with shadow for depth
draw.text((om_x + 3, om_y + 3), om_text, font=om_font, fill=colors["shadow"])
draw.text((om_x, om_y), om_text, font=om_font, fill=colors["om"])

# Save the icon
output_path = "GitaPearls/Assets.xcassets/AppIcon.appiconset/Icon-1024.png"
img.save(output_path, "PNG")
print(f"✅ App icon saved to: {output_path}")

# Also save a copy in the root for easy access
img.save("app-icon-1024.png", "PNG")
print(f"✅ Copy saved to: app-icon-1024.png")

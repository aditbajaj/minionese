shader_type canvas_item;

// Broad slider: 0.0 means filter nothing, 1.0 filters everything
uniform float remove_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Get the overall brightness/grayscale value of the pixel
    float luma = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    
    // Check if the color channels are close to each other (which makes it gray)
    float max_ch = max(max(tex_color.r, tex_color.g), tex_color.b);
    float min_ch = min(min(tex_color.r, tex_color.g), tex_color.b);
    float is_gray = 1.0 - (max_ch - min_ch);
    
    // If it's gray, and within our removal threshold, force alpha to 0
    if (is_gray > 0.9 && luma > 0.1 && luma < 0.9) {
        tex_color.a *= (1.0 - remove_amount);
    }
    
    // Force transparency update
    if (tex_color.a < 0.1) {
        discard;
    }

    COLOR = tex_color;
}

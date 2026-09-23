shader_type canvas_item;

// Re-colours the minion art onto a purple ramp instead of tinting it,
// which is the only way to get purple out of a yellow sprite.
uniform vec3 shadow : source_color = vec3(0.16, 0.05, 0.28);
uniform vec3 mid : source_color = vec3(0.52, 0.24, 0.82);
uniform vec3 light : source_color = vec3(0.86, 0.66, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luma = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

	vec3 tinted = luma < 0.5
		? mix(shadow, mid, luma * 2.0)
		: mix(mid, light, (luma - 0.5) * 2.0);

	COLOR = vec4(tinted, tex_color.a);
}

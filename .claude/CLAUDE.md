# Found Fishin

Godot 4.7 2D fishing prototype, GDScript.

## Naming

Use descriptive variable names that say what the value means. No cryptic abbreviations.

- Bad: `d`, `l`, `v`, `x`, `dir`, `dist`, `vel`, `grav`, `damp`, `corr`, `pts`, `prev`
- Good: `gap`, `gap_len`, `dir_to_anchor`, `dist_to_anchor`, `radial_velocity`, `gravity`, `momentum_kept`, `correction`, `rope_points`
- Name what a value actually is, not roughly what it is: a per-tick displacement is `carried_motion`, not `vel`; a retention factor is `momentum_kept`, not `damp`; a maximum is `max_gap_len`, not `seg_len`; a point count is `point_count`, not `segments`.
- Prefix ambiguous exports with what they belong to (`max_line_length`, `line_stiffness`, not `max_length`, `stiffness`).
- Loop indices (`i`) and ignored loop variables (`_iter`) are fine as short names.
- Don't shadow built-in node properties (e.g. `Line2D.points`, `CharacterBody2D.velocity`) with local names.

## No magic numbers

Tuning values (speeds, gravities, damping factors, iteration counts, amounts, positions) go in descriptively named `@export` properties, not inline literals. Use `@export_range` for bounded values like 0–1 factors. Pure math constants (the `0.5` in a half-split, `1.0 - exp(...)`) can stay inline.

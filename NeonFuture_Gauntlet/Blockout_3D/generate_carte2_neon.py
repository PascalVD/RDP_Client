"""
=====================================================================
 NEON FUTURE - GAUNTLET / CARTE 2
 generate_carte2_neon.py
 Genere le blockout 3D low-poly de l'ARENE de survie "Neon Future"
 (Carte 2) et l'exporte en FBX + GLB pour UEFN.

 Concept d'arene (solo / free-for-all, gauntlet a elimination) :
 - Une grande plateforme circulaire neon (l'arene de combat).
 - Un anneau exterieur = "zone qui retrecit" (repere visuel du ShrinkZone).
 - Des couloirs laser (LaserSweep) traversant l'arene.
 - Des dalles "PulseFloor" au centre.
 - Des blocs de couverture (cover) repartis pour le combat.
 - 8 pads d'ENTREE (arrivee des survivants) sur le pourtour.
 - 1 pad de SORTIE (survivants -> carte suivante) au centre sureleve.

 Lancement :
     blender --background --python generate_carte2_neon.py
 Sorties dans ./export/ (FBX principal + GLB + parts/).

 Echelle : 1 unite Blender = 1 metre. Import UEFN : x100 (cm).
=====================================================================
"""

import bpy
import math
import os

EXPORT_DIR = os.path.join(os.path.dirname(bpy.data.filepath) or os.getcwd(), "export")
PARTS_DIR = os.path.join(EXPORT_DIR, "parts")

# Ambiance neon (emissif fort pour le rendu nuit futuriste).
MATERIALS = {
    "floor":   (0.06, 0.07, 0.12),   # sol sombre
    "neon_cyan":  (0.05, 0.85, 0.95),
    "neon_magenta": (0.95, 0.10, 0.70),
    "neon_purple": (0.55, 0.15, 0.95),
    "cover":   (0.15, 0.16, 0.22),   # blocs de couverture
    "laser":   (0.95, 0.15, 0.25),   # couloirs laser (danger)
    "pulse":   (0.95, 0.55, 0.05),   # dalles pulsantes
    "shrink":  (0.10, 0.90, 0.60),   # anneau zone de securite
    "exit":    (0.95, 0.90, 0.10),   # pad de sortie
    "entry":   (0.10, 0.60, 0.95),   # pads d'entree
}
EMISSIVE = {"neon_cyan", "neon_magenta", "neon_purple", "laser", "pulse",
            "shrink", "exit", "entry"}

ARENA_RADIUS = 40.0     # rayon de la plateforme principale (m)
WALL_HEIGHT = 6.0


def reset_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in (bpy.data.meshes, bpy.data.materials):
        for item in list(block):
            block.remove(item)


def get_material(name):
    key = f"MAT_{name}"
    if key in bpy.data.materials:
        return bpy.data.materials[key]
    mat = bpy.data.materials.new(key)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    r, g, b = MATERIALS.get(name, (0.6, 0.6, 0.6))
    bsdf.inputs["Base Color"].default_value = (r, g, b, 1.0)
    if name in EMISSIVE and "Emission Color" in bsdf.inputs:
        bsdf.inputs["Emission Color"].default_value = (r, g, b, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 3.0
    return mat


def assign(obj, name):
    obj.data.materials.clear()
    obj.data.materials.append(get_material(name))
    return obj


def add_box(name, loc, size, mat):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(scale=True)
    return assign(o, mat)


def add_cylinder(name, loc, radius, depth, mat, verts=48):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius,
                                         depth=depth, location=loc)
    o = bpy.context.active_object
    o.name = name
    return assign(o, mat)


def add_ring(name, loc, radius, thickness, height, mat, verts=64):
    # Anneau = tore aplati (repere de zone).
    bpy.ops.mesh.primitive_torus_add(location=loc, major_radius=radius,
                                     minor_radius=thickness,
                                     major_segments=verts, minor_segments=8)
    o = bpy.context.active_object
    o.name = name
    o.scale = (1, 1, max(0.05, height / (thickness * 2)))
    bpy.ops.object.transform_apply(scale=True)
    return assign(o, mat)


def build_arena():
    reset_scene()

    # Sol principal (grande plateforme circulaire).
    add_cylinder("BL_Arena_Floor", (0, 0, -0.25), ARENA_RADIUS, 0.5, "floor")

    # Bordure neon lumineuse tout autour.
    add_ring("BL_Arena_NeonRim", (0, 0, 0.2), ARENA_RADIUS - 0.5, 0.6, 0.6, "neon_cyan")

    # Mur bas de securite (empeche de tomber) alterne cyan/magenta.
    segs = 24
    for i in range(segs):
        a = (2 * math.pi / segs) * i
        x = math.cos(a) * (ARENA_RADIUS - 0.2)
        y = math.sin(a) * (ARENA_RADIUS - 0.2)
        col = "neon_cyan" if i % 2 == 0 else "neon_magenta"
        b = add_box(f"BL_Wall_{i}", (x, y, WALL_HEIGHT / 2),
                    (2.0, 0.4, WALL_HEIGHT), col)
        b.rotation_euler = (0, 0, a)
        bpy.context.view_layer.objects.active = b
        bpy.ops.object.transform_apply(rotation=True)

    # Anneau "zone qui retrecit" (repere visuel du ShrinkZone hazard).
    add_ring("BL_ShrinkZone_Marker", (0, 0, 0.05), ARENA_RADIUS * 0.62, 0.4, 0.3, "shrink")

    # Couloirs laser (2 bandes croisees) = LaserSweep hazard.
    add_box("BL_LaserLane_X", (0, 0, 0.15), (ARENA_RADIUS * 2, 3.0, 0.1), "laser")
    add_box("BL_LaserLane_Y", (0, 0, 0.15), (3.0, ARENA_RADIUS * 2, 0.1), "laser")

    # Dalles pulsantes au centre (PulseFloor) : grille 4x4.
    for gx in range(-2, 2):
        for gy in range(-2, 2):
            add_box(f"BL_Pulse_{gx}_{gy}",
                    (gx * 3 + 1.5, gy * 3 + 1.5, 0.05),
                    (2.6, 2.6, 0.1), "pulse")

    # Blocs de couverture repartis en anneau (combat FFA).
    covers = 10
    for i in range(covers):
        a = (2 * math.pi / covers) * i + 0.3
        r = ARENA_RADIUS * 0.45
        x, y = math.cos(a) * r, math.sin(a) * r
        add_box(f"BL_Cover_{i}", (x, y, 1.25), (3.0, 1.0, 2.5), "cover")

    # 8 pads d'ENTREE (arrivee des survivants) sur le pourtour.
    entries = 8
    for i in range(entries):
        a = (2 * math.pi / entries) * i
        r = ARENA_RADIUS * 0.82
        x, y = math.cos(a) * r, math.sin(a) * r
        add_cylinder(f"BL_EntryPad_{i}", (x, y, 0.1), 2.0, 0.2, "entry", verts=24)

    # Pad de SORTIE central surleve (survivants -> carte suivante).
    add_cylinder("BL_ExitPad_Base", (0, 0, 0.6), 4.0, 1.2, "neon_purple", verts=32)
    add_cylinder("BL_ExitPad", (0, 0, 1.3), 3.0, 0.3, "exit", verts=32)

    print(">> Arene Neon Future (Carte 2) :", len(bpy.data.objects), "objets.")


def export_all():
    os.makedirs(EXPORT_DIR, exist_ok=True)
    os.makedirs(PARTS_DIR, exist_ok=True)

    blend = os.path.join(EXPORT_DIR, "Carte2_NeonFuture.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend)
    print(">> .blend :", blend)

    fbx = os.path.join(EXPORT_DIR, "Carte2_NeonFuture.fbx")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.fbx(filepath=fbx, use_selection=True,
                             apply_scale_options="FBX_SCALE_ALL",
                             mesh_smooth_type="FACE")
    print(">> FBX :", fbx)

    glb = os.path.join(EXPORT_DIR, "Carte2_NeonFuture.glb")
    bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB", use_selection=False)
    print(">> GLB :", glb)

    for obj in bpy.data.objects:
        if not obj.name.startswith("BL_"):
            continue
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.export_scene.fbx(
            filepath=os.path.join(PARTS_DIR, f"{obj.name}.fbx"),
            use_selection=True, apply_scale_options="FBX_SCALE_ALL")
    print(">> parts/ exportes.")


if __name__ == "__main__":
    build_arena()
    export_all()
    print("=== TERMINE. Importez export/Carte2_NeonFuture.fbx dans UEFN. ===")

"""
=====================================================================
 CITY HEIST - POLICE VS VOLEURS
 generate_blockout.py
 Genere automatiquement un blockout 3D low-poly de toute la map et
 l'exporte en FBX + GLB, pret a importer dans UEFN.

 UTILISATION
 -----------
 1. Installez Blender 3.6+ (gratuit : https://www.blender.org).
 2. Lancez en ligne de commande (recommande, pas besoin d'ouvrir l'UI) :

        blender --background --python generate_blockout.py

    Ou dans Blender : Scripting > Open > generate_blockout.py > Run.

 3. Les fichiers sont ecrits dans ./export/ :
        CityHeist_Blockout.blend
        CityHeist_Blockout.fbx     (import UEFN principal)
        CityHeist_Blockout.glb     (alternative / preview)
    + un FBX par batiment dans ./export/parts/ pour un import modulaire.

 ECHELLE
 -------
 Tout est en METRES (1 unite Blender = 1 m). A l'import FBX dans UEFN,
 utilisez une echelle de 100 (UEFN/Unreal travaille en centimetres) ou
 cochez "Convert Scene Unit". Voir Build_Instructions/UEFN_Import_Guide.md.

 Le plan de placement (coordonnees) correspond a Docs/Placement_Plan.md.
 Les unites "X -120 / Y 0" du brief sont interpretees en metres ici.

 PRINCIPES BLOCKOUT
 ------------------
 - Volumes simples (cubes/plans), collisions implicites simples.
 - Murs creux avec ouvertures (portes/fenetres) decoupees par booleen.
 - Code couleur par materiau (bleu police, orange voleurs, neon...).
 - Chaque batiment est un objet nomme clairement (prefixe BL_).
=====================================================================
"""

import bpy
import bmesh
import math
import os

# --------------------------------------------------------------------
# CONFIG GLOBALE
# --------------------------------------------------------------------
EXPORT_DIR = os.path.join(os.path.dirname(bpy.data.filepath) or os.getcwd(), "export")
PARTS_DIR = os.path.join(EXPORT_DIR, "parts")
WALL_THICKNESS = 0.3
FLOOR_THICKNESS = 0.2

# Plan de placement (metres). Cf. Docs/Placement_Plan.md.
# Brief : echelle "X -120, Y 0" -> on multiplie par un facteur ville.
SCALE = 1.0  # 1 unite plan = 1 metre
LAYOUT = {
    # nom            : (x,    y,    largeur, profondeur, hauteur, couleur)
    "Commissariat":    (-120,   0,   28, 22, 9,  "police"),
    "Prison":          (-120, -40,   22, 18, 7,  "police"),
    "Banque":          (   0,   0,   34, 30, 14, "civic"),
    "ParkingSousSol":  (   0, -30,   34, 30, 4,  "concrete"),  # sous la banque (z negatif a l'export)
    "Bijouterie":      (  40,  60,   16, 14, 7,  "neon"),
    "Casino":          (  80,-120,   30, 26, 12, "neon"),
    "PlanqueVoleurs":  ( 140, -80,   24, 20, 8,  "voleurs"),
    "QuartierResid_1": ( 150,  80,   12, 10, 6,  "house"),
    "QuartierResid_2": ( 168,  80,   12, 10, 6,  "house"),
    "QuartierResid_3": ( 150,  98,   12, 10, 6,  "house"),
    "QuartierResid_4": ( 168,  98,   12, 10, 6,  "house"),
    "Superette":       (  60,  10,   14, 12, 6,  "neon"),
    "StationEssence":  (  64,  -8,   18,  8, 5,  "concrete"),
}

# Materiaux (R, G, B) - ambiance nuit stylisee.
MATERIALS = {
    "police":   (0.10, 0.25, 0.65),   # bleu
    "voleurs":  (0.85, 0.45, 0.10),   # orange
    "civic":    (0.55, 0.55, 0.60),   # gris pierre (banque)
    "neon":     (0.80, 0.15, 0.55),   # rose neon (casino/bijouterie/superette)
    "concrete": (0.30, 0.30, 0.33),   # beton (parking/station)
    "house":    (0.45, 0.40, 0.35),   # maison residentielle
    "road":     (0.08, 0.08, 0.10),   # asphalte
    "sidewalk": (0.40, 0.40, 0.43),   # trottoir
    "sewer":    (0.15, 0.20, 0.18),   # egouts
    "barricade":(0.90, 0.75, 0.05),   # barrage police jaune
    "ground":   (0.05, 0.07, 0.09),   # sol ville nuit
}


# --------------------------------------------------------------------
# HELPERS
# --------------------------------------------------------------------
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
    # Leger emissif pour les neons (ambiance nuit).
    if name in ("neon", "barricade"):
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (r, g, b, 1.0)
            bsdf.inputs["Emission Strength"].default_value = 2.0
    return mat


def assign_material(obj, name):
    obj.data.materials.clear()
    obj.data.materials.append(get_material(name))


def add_box(name, location, size, material):
    """Cube plein nomme, centre sur location, dimensions = size (x,y,z)."""
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (size[0] / 2.0, size[1] / 2.0, size[2] / 2.0)
    bpy.ops.object.transform_apply(scale=True)
    assign_material(obj, material)
    return obj


def boolean_cut(target, cutter):
    """Soustrait cutter de target (pour percer portes/fenetres)."""
    mod = target.modifiers.new(name="cut", type="BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.object = cutter
    bpy.context.view_layer.objects.active = target
    bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.data.objects.remove(cutter, do_unlink=True)


def make_building(name, x, y, w, d, h, material, door="south", windows=True):
    """
    Genere un batiment blockout creux : 4 murs + sol + toit plat,
    avec une porte et (option) des fenetres. Retourne l'objet joint.
    """
    z0 = h / 2.0
    parts = []
    # Sol
    parts.append(add_box(f"{name}_Floor", (x, y, FLOOR_THICKNESS / 2), (w, d, FLOOR_THICKNESS), material))
    # Toit plat
    parts.append(add_box(f"{name}_Roof", (x, y, h - FLOOR_THICKNESS / 2), (w, d, FLOOR_THICKNESS), material))
    # Murs (cadre creux : 4 parois fines)
    wall_specs = [
        (f"{name}_WallN", (x, y + d / 2, z0), (w, WALL_THICKNESS, h)),
        (f"{name}_WallS", (x, y - d / 2, z0), (w, WALL_THICKNESS, h)),
        (f"{name}_WallE", (x + w / 2, y, z0), (WALL_THICKNESS, d, h)),
        (f"{name}_WallW", (x - w / 2, y, z0), (WALL_THICKNESS, d, h)),
    ]
    walls = {s[0][-1]: add_box(*s, material) for s in wall_specs}

    # Porte : percee dans le mur choisi (defaut sud).
    door_w, door_h = 2.2, 3.0
    door_targets = {
        "south": (walls["S"], (x, y - d / 2, door_h / 2), (door_w, WALL_THICKNESS * 3, door_h)),
        "north": (walls["N"], (x, y + d / 2, door_h / 2), (door_w, WALL_THICKNESS * 3, door_h)),
        "east":  (walls["E"], (x + w / 2, y, door_h / 2), (WALL_THICKNESS * 3, door_w, door_h)),
        "west":  (walls["W"], (x - w / 2, y, door_h / 2), (WALL_THICKNESS * 3, door_w, door_h)),
    }
    tgt, loc, siz = door_targets.get(door, door_targets["south"])
    cutter = add_box(f"{name}_DoorCut", loc, siz, material)
    boolean_cut(tgt, cutter)

    # Fenetres simples sur les murs E/W.
    if windows:
        win_w, win_h = 1.4, 1.6
        win_z = h * 0.55
        for wall_key, wx in (("E", x + w / 2), ("W", x - w / 2)):
            for off in (-d / 4, d / 4):
                c = add_box(f"{name}_WinCut", (wx, y + off, win_z),
                            (WALL_THICKNESS * 3, win_w, win_h), material)
                boolean_cut(walls[wall_key], c)

    # Joindre toutes les pieces en un seul objet "BL_<name>".
    for p in parts:
        p.select_set(True)
    for w_obj in walls.values():
        w_obj.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = f"BL_{name}"
    assign_material(obj, material)
    return obj


def make_road(name, x, y, length, width, horizontal=True):
    """Bande de route plate (asphalte) + trottoirs."""
    if horizontal:
        road = add_box(f"BL_{name}", (x, y, 0.05), (length, width, 0.1), "road")
        add_box(f"BL_{name}_SwN", (x, y + width / 2 + 1, 0.1), (length, 2, 0.2), "sidewalk")
        add_box(f"BL_{name}_SwS", (x, y - width / 2 - 1, 0.1), (length, 2, 0.2), "sidewalk")
    else:
        road = add_box(f"BL_{name}", (x, y, 0.05), (width, length, 0.1), "road")
        add_box(f"BL_{name}_SwE", (x + width / 2 + 1, y, 0.1), (2, length, 0.2), "sidewalk")
        add_box(f"BL_{name}_SwW", (x - width / 2 - 1, y, 0.1), (2, length, 0.2), "sidewalk")
    return road


def make_sewer_entrance(name, x, y):
    """Entree d'egout : trappe + amorce de tunnel sous le sol (z negatif)."""
    add_box(f"BL_Sewer_{name}_Hatch", (x, y, 0.15), (2, 2, 0.3), "sewer")
    add_box(f"BL_Sewer_{name}_Shaft", (x, y, -2.0), (2.5, 2.5, 4.0), "sewer")


def make_barricade(name, x, y, horizontal=True):
    """Barrage de police (barriere basse)."""
    if horizontal:
        add_box(f"BL_Barricade_{name}", (x, y, 0.6), (6, 0.6, 1.2), "barricade")
    else:
        add_box(f"BL_Barricade_{name}", (x, y, 0.6), (0.6, 6, 1.2), "barricade")


# --------------------------------------------------------------------
# CONSTRUCTION DE LA MAP
# --------------------------------------------------------------------
def build_map():
    reset_scene()

    # Sol global de la ville (grande dalle nuit).
    add_box("BL_Ground", (20, 0, -0.1), (420, 360, 0.2), "ground")

    # Batiments.
    door_map = {
        "Commissariat": "east",
        "Prison": "north",
        "Banque": "south",
        "Bijouterie": "south",
        "Casino": "west",
        "PlanqueVoleurs": "west",
        "Superette": "south",
    }
    for name, (x, y, w, d, h, mat) in LAYOUT.items():
        if name == "ParkingSousSol":
            # Parking : sous la banque, z negatif, sans fenetres, ouvert.
            obj = make_building(name, x, y, w, d, h, mat, door="north", windows=False)
            obj.location.z -= (h + 1)  # descend sous le sol
            continue
        if name == "StationEssence":
            # Station : structure ouverte (auvent) + 2 pompes.
            add_box(f"BL_{name}_Canopy", (x, y, h), (w, d, 0.4), mat)
            add_box(f"BL_{name}_Pillar1", (x - w / 3, y, h / 2), (0.6, 0.6, h), mat)
            add_box(f"BL_{name}_Pillar2", (x + w / 3, y, h / 2), (0.6, 0.6, h), mat)
            add_box(f"BL_{name}_Pump1", (x - 2, y, 0.9), (1, 0.6, 1.8), "neon")
            add_box(f"BL_{name}_Pump2", (x + 2, y, 0.9), (1, 0.6, 1.8), "neon")
            continue
        make_building(name, x, y, w, d, h, mat,
                      door=door_map.get(name, "south"),
                      windows=name.startswith("QuartierResid") is False)

    # Reseau routier principal (large pour vehicules).
    make_road("Route_Principale", 20, 0, 360, 12, horizontal=True)     # E-O au centre
    make_road("Route_Verticale", 0, 0, 320, 12, horizontal=False)      # N-S sur la banque
    make_road("Route_Casino", 80, -60, 140, 10, horizontal=False)
    make_road("Route_Planque", 140, -40, 100, 10, horizontal=False)
    make_road("Route_Resid", 159, 90, 60, 8, horizontal=True)

    # Entrees d'egouts (reliant planque/banque/parking/quartier).
    make_sewer_entrance("Banque", 18, -10)
    make_sewer_entrance("Planque", 125, -78)
    make_sewer_entrance("Parking", 5, -28)
    make_sewer_entrance("Quartier", 152, 70)
    make_sewer_entrance("Casino", 95, -110)

    # Barrages de police (points de controle).
    make_barricade("Centre", 30, 6, horizontal=True)
    make_barricade("BanqueSud", 0, -20, horizontal=True)
    make_barricade("Casino", 80, -90, horizontal=False)

    print(">> Blockout construit :", len(bpy.data.objects), "objets.")


# --------------------------------------------------------------------
# EXPORT
# --------------------------------------------------------------------
def export_all():
    os.makedirs(EXPORT_DIR, exist_ok=True)
    os.makedirs(PARTS_DIR, exist_ok=True)

    blend_path = os.path.join(EXPORT_DIR, "CityHeist_Blockout.blend")
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)
    print(">> Sauvegarde .blend :", blend_path)

    # FBX global.
    fbx_path = os.path.join(EXPORT_DIR, "CityHeist_Blockout.fbx")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.fbx(
        filepath=fbx_path,
        use_selection=True,
        apply_scale_options="FBX_SCALE_ALL",
        mesh_smooth_type="FACE",
        path_mode="COPY",
    )
    print(">> Export FBX :", fbx_path)

    # GLB global.
    glb_path = os.path.join(EXPORT_DIR, "CityHeist_Blockout.glb")
    bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB", use_selection=False)
    print(">> Export GLB :", glb_path)

    # Export modulaire : un FBX par batiment (prefixe BL_).
    for obj in bpy.data.objects:
        if not obj.name.startswith("BL_"):
            continue
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        part_path = os.path.join(PARTS_DIR, f"{obj.name}.fbx")
        bpy.ops.export_scene.fbx(filepath=part_path, use_selection=True,
                                 apply_scale_options="FBX_SCALE_ALL")
    print(">> Exports modulaires dans :", PARTS_DIR)


if __name__ == "__main__":
    build_map()
    export_all()
    print("=== TERMINE. Importez export/CityHeist_Blockout.fbx dans UEFN. ===")

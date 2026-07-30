package collision

import glm "core:math/linalg/glsl"

Collider_Type :: enum {
    BOX,
    SPHERE,
    CAPSULE,
    CYLINDER,
    HULL,
}

Collider :: struct {
    type: Collider_Type,

    // transform
    position: glm.vec3,
    rotation: glm.quat,

    // shape
    extent: glm.vec3,
    vertices: [dynamic]glm.vec3,
}

make_collider_box :: proc(collider: ^Collider, position: glm.vec3, extent: glm.vec3) {
    collider.type = .BOX
    collider.position = position
    collider.extent = extent
}

make_collider_sphere :: proc(collider: ^Collider, position: glm.vec3, radius: f32) {
    collider.type = .SPHERE
    collider.position = position
    collider.extent = radius
}

make_collider_capsule :: proc(collider: ^Collider, position: glm.vec3, radius: f32, extent: f32) {
    collider.type = .CAPSULE
    collider.position = position
    collider.extent = {radius, extent, radius}
}

make_collider_cylinder :: proc(collider: ^Collider, position: glm.vec3, radius: f32, extent: f32) {
    collider.type = .CYLINDER
    collider.position = position
    collider.extent = {radius, extent, radius}
}

make_collider_hull :: proc(collider: ^Collider, position: glm.vec3, vertices: []glm.vec3) {
    collider.type = .HULL
    collider.position = position
    collider.extent = calc_hull_extent(vertices)
    append(&collider.vertices, ..vertices)
}

delete_collider :: proc(collider: Collider) {
    delete(collider.vertices)
}

calc_collider_bounds :: proc(collider: ^Collider) -> (glm.vec3, glm.vec3) {
    return collider.position - collider.extent, collider.position + collider.extent
}

calc_collider_radius :: proc(collider: ^Collider) -> f32 {
    return glm.max(glm.max(collider.extent.x, collider.extent.y), collider.extent.z)
}

support :: proc(collider: Collider, dir: glm.vec3) -> glm.vec3 {
    dir := glm.normalize(dir)
    local_dir := glm.quatMulVec3(conj(collider.rotation), dir)
    result: glm.vec3

    switch collider.type {
    case .BOX:
        result = {
            local_dir.x < 0 ? -collider.extent.x : collider.extent.x,
            local_dir.y < 0 ? -collider.extent.y : collider.extent.y,
            local_dir.z < 0 ? -collider.extent.z : collider.extent.z
        }
    case .SPHERE:
        result = local_dir * collider.extent.x
    case .CAPSULE:
        result = local_dir * collider.extent.x
        result.y += local_dir.y > 0 ? collider.extent.y : -collider.extent.y
    case .CYLINDER:
        result = glm.normalize(glm.vec3{local_dir.x, 0, local_dir.z}) * collider.extent.x
        result.y = local_dir.y > 0 ? collider.extent.y : -collider.extent.y
    case .HULL:
        vertex_max := collider.vertices[0]
        dot_max := glm.dot(vertex_max, local_dir)

        for i in 1 ..< len(collider.vertices) {
            vertex := collider.vertices[i]
            dot := glm.dot(vertex, local_dir)

            if dot > dot_max {
                vertex_max = vertex
                dot_max = dot
            }
        }

        result = vertex_max
    }

    return glm.quatMulVec3(collider.rotation, result) + collider.position
}

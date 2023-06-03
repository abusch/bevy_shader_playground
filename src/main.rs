use bevy::{
    prelude::{shape::Quad, *},
    reflect::TypeUuid,
    render::render_resource::{AsBindGroup, ShaderRef},
    sprite::{Material2d, Material2dPlugin, MaterialMesh2dBundle},
};

// The default size of the window. Adjust as needed.
const WINDOW_SIZE: Vec2 = Vec2::new(800.0, 800.0);

fn main() {
    App::new()
        .add_plugins(
            DefaultPlugins
                // Set the default window size
                .set(WindowPlugin {
                    primary_window: Some(Window {
                        resolution: WINDOW_SIZE.into(),
                        ..default()
                    }),
                    ..default()
                })
                // Enable hot-reloading of shaders
                .set(AssetPlugin {
                    watch_for_changes: true,
                    ..default()
                }),
        )
        // Register our custom material
        .add_plugin(Material2dPlugin::<CustomMaterial>::default())
        .add_startup_system(setup)
        .run();
}

/// This system is run once on startup and sets up a default 2D Camera, as well as a quad mesh big
/// enough to cover the whole window and using our custom material.
fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<CustomMaterial>>,
) {
    // Create the default 2D camera. It is basically an orthographic camera that sits somewhere
    // along the Z-axis and looks down towards the XY plane.
    commands.spawn(Camera2dBundle::default());

    // Create a quad mesh with our custom material
    commands.spawn(MaterialMesh2dBundle {
        mesh: meshes.add(Mesh::from(Quad::new(WINDOW_SIZE))).into(),
        material: materials.add(CustomMaterial {
            spatial_repetition: 2.0,
        }),
        ..default()
    });
}

/// Our custom material, that will basically run our WGSL shader.
///
/// At the moment the struct is empty, but you can define some fields that can be bound to the
/// shader. Then in your shader you can define a matching `CustomMaterial` struct to receive those
/// values.
#[derive(AsBindGroup, TypeUuid, Debug, Clone)]
#[uuid = "515FB3B6-17D8-49C0-8C36-96BBD337A5B2"]
pub struct CustomMaterial {
    #[uniform(0)]
    pub spatial_repetition: f32,
}

// Since we're using a 2D camera and a 2D mesh, we're implementing `Material2d` here.
impl Material2d for CustomMaterial {
    // Overload this method to use our fragment shader instead of the default one.
    fn fragment_shader() -> ShaderRef {
        // The path is relative to the top-level `assets` directory. By default, Bevy will look for
        // an entry point called `fragment`.
        "shaders/custom_shader.wgsl".into()
    }

    // Overload this method to customize the render pipeline (if you want to use a different entry
    // point for instance).
    fn specialize(
        descriptor: &mut bevy::render::render_resource::RenderPipelineDescriptor,
        _layout: &bevy::render::mesh::MeshVertexBufferLayout,
        _key: bevy::sprite::Material2dKey<Self>,
    ) -> Result<(), bevy::render::render_resource::SpecializedMeshPipelineError> {
        if let Some(mut state) = descriptor.fragment.as_mut() {
            state.entry_point = "my_entry_point".into();
        }
        Ok(())
    }
}

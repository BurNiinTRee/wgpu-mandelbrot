use std::{
    env, fs,
    io::Write,
    path::{Path, PathBuf},
};

fn main() {
    compile_shader("src/shader.vert", shaderc::ShaderKind::Vertex);
    compile_shader("src/shader.frag", shaderc::ShaderKind::Fragment);
}

fn compile_shader<P: AsRef<Path>>(path: P, shader_type: shaderc::ShaderKind) {
    let path: &Path = path.as_ref();
    println!("cargo:rerun-if-changed={}", path.display());
    let source = fs::read_to_string(path).unwrap();

    let mut compiler = shaderc::Compiler::new().unwrap();
    let binary_result = compiler
        .compile_into_spirv(&source, shader_type, "shader.vert", "main", None)
        .unwrap();

    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let mut out_name = path.file_name().unwrap().to_str().unwrap().to_owned();
    let mut out_file = fs::File::create(out_dir.join(&out_name)).unwrap();
    out_file.write_all(binary_result.as_binary_u8()).unwrap();
}

use std::{env, fs, io::Write, path::PathBuf};

fn main() {
    compile_shader("shader.vert", shaderc::ShaderKind::Vertex);
    compile_shader("shader.frag", shaderc::ShaderKind::Fragment);
}

fn compile_shader(name: &str, shader_type: shaderc::ShaderKind) {
    let mut src_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    src_dir.push("src");
    println!("cargo:rerun-if-changed={}", src_dir.join(name).display());
    let source = fs::read_to_string(src_dir.join(name)).unwrap();

    let mut compiler = shaderc::Compiler::new().unwrap();
    let binary_result = compiler
        .compile_into_spirv(&source, shader_type, "shader.vert", "main", None)
        .unwrap();

    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let mut out_name = name.to_string();
    out_name.push_str(".spirv");
    let mut out_file = fs::File::create(out_dir.join(&out_name)).unwrap();
    out_file.write_all(binary_result.as_binary_u8()).unwrap();
}

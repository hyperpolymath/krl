// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// KRL FFI build configuration.
//
// Exposes two steps:
//   zig build        — build the static library consumed over the C ABI
//   zig build test   — run the FFI unit tests in src/main.zig

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ffi_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "krl",
        .linkage = .static,
        .root_module = ffi_mod,
    });
    b.installArtifact(lib);

    const ffi_tests = b.addTest(.{ .root_module = ffi_mod });
    const run_ffi_tests = b.addRunArtifact(ffi_tests);

    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_ffi_tests.step);
}

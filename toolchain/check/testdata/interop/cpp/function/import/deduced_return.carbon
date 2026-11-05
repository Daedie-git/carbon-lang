// Part of the Carbon Language project, under the Apache License v2.0 with LLVM
// Exceptions. See /LICENSE for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// INCLUDE-FILE: toolchain/testing/testdata/min_prelude/int.carbon
//
// AUTOUPDATE
// TIP: To test this file alone, run:
// TIP:   bazel test //toolchain/testing:file_test --test_arg=--file_tests=toolchain/check/testdata/interop/cpp/function/import/deduced_return.carbon
// TIP: To dump output, run:
// TIP:   bazel run //toolchain/testing:file_test -- --dump_output --file_tests=toolchain/check/testdata/interop/cpp/function/import/deduced_return.carbon

// --- function.carbon

library "[[@TEST_NAME]]";

import Cpp inline '''
template <typename T>
auto Identity(T value) { return value; }
''';

fn Call(x: i32) -> i32 {
  //@dump-sem-ir-begin
  return Cpp.Identity(x);
  //@dump-sem-ir-end
}

// --- operator.carbon

library "[[@TEST_NAME]]";

import Cpp inline '''
struct Value { int value; };
template <typename T>
auto operator+(T left, T right) { return left.value + right.value; }
''';

fn Add(left: Cpp.Value, right: Cpp.Value) -> i32 {
  //@dump-sem-ir-begin
  return left + right;
  //@dump-sem-ir-end
}

// --- fail_body_error.carbon

library "[[@TEST_NAME]]";

import Cpp inline '''
template <typename T>
// CHECK:STDERR:        ╭─┤ fail_body_error.carbon:[[@LINE+14]]:37
// CHECK:STDERR: ->     │ auto Invalid(T value) { return value.missing; }
// CHECK:STDERR:        ·                                ────╴╻╶──────
// CHECK:STDERR:        ·                                     ┗━━┫ error: member reference base type 'int'
// CHECK:STDERR:        ·                                        ┃        is not a structure or union
// CHECK:STDERR:        ·                                        ┃        [CppInteropParseError]
// CHECK:STDERR:        ┆
// CHECK:STDERR:        │   Cpp.Invalid(x);
// CHECK:STDERR:        ·   ┬
// CHECK:STDERR:        ·   ╰──┤ in instantiation of function template specialization 'Invalid<int>'
// CHECK:STDERR:        ·      │ requested here
// CHECK:STDERR:        ·      │ [CppInteropParseNote]
// CHECK:STDERR:        ╰────
// CHECK:STDERR:
auto Invalid(T value) { return value.missing; }
''';

fn Call(x: i32) {
  Cpp.Invalid(x);
}

// CHECK:STDOUT: --- function.carbon
// CHECK:STDOUT:
// CHECK:STDOUT: constants {
// CHECK:STDOUT:   type: type = facet_type <type> [concrete]
// CHECK:STDOUT:   %int_32: Core.IntLiteral = int_value 32 [concrete]
// CHECK:STDOUT:   %i32: type = class_type @Int, @Int(%int_32) [concrete]
// CHECK:STDOUT:   %Identity.cpp_overload_set.type: type = cpp_overload_set_type @Identity.cpp_overload_set [concrete]
// CHECK:STDOUT:   %Identity.cpp_overload_set.value: %Identity.cpp_overload_set.type = cpp_overload_set_value @Identity.cpp_overload_set [concrete]
// CHECK:STDOUT:   %Identity.type: type = fn_type @Identity [concrete]
// CHECK:STDOUT:   %Identity: %Identity.type = struct_value () [concrete]
// CHECK:STDOUT: }
// CHECK:STDOUT:
// CHECK:STDOUT: imports {
// CHECK:STDOUT:   %Cpp: <namespace> = namespace file.%Cpp.import_cpp, [concrete] {
// CHECK:STDOUT:     .Identity = %Identity.cpp_overload_set.value
// CHECK:STDOUT:     import Cpp//...
// CHECK:STDOUT:   }
// CHECK:STDOUT:   %Identity.cpp_overload_set.value: %Identity.cpp_overload_set.type = cpp_overload_set_value @Identity.cpp_overload_set [concrete = constants.%Identity.cpp_overload_set.value]
// CHECK:STDOUT:   %Identity.decl: %Identity.type = fn_decl @Identity [concrete = constants.%Identity] {
// CHECK:STDOUT:     <elided>
// CHECK:STDOUT:   } {
// CHECK:STDOUT:     <elided>
// CHECK:STDOUT:   }
// CHECK:STDOUT: }
// CHECK:STDOUT:
// CHECK:STDOUT: fn @Call(%x.param: %i32) -> out %return.param: %i32 {
// CHECK:STDOUT: !entry:
// CHECK:STDOUT:   %Cpp.ref: <namespace> = name_ref Cpp, imports.%Cpp [concrete = imports.%Cpp]
// CHECK:STDOUT:   %Identity.ref: %Identity.cpp_overload_set.type = name_ref Identity, imports.%Identity.cpp_overload_set.value [concrete = constants.%Identity.cpp_overload_set.value]
// CHECK:STDOUT:   %x.ref: %i32 = name_ref x, %x
// CHECK:STDOUT:   %Identity.call: init %i32 = call imports.%Identity.decl(%x.ref)
// CHECK:STDOUT:   return %Identity.call
// CHECK:STDOUT: }
// CHECK:STDOUT:
// CHECK:STDOUT: --- operator.carbon
// CHECK:STDOUT:
// CHECK:STDOUT: constants {
// CHECK:STDOUT:   type: type = facet_type <type> [concrete]
// CHECK:STDOUT:   %Value: type = class_type @Value [concrete]
// CHECK:STDOUT:   %int_32: Core.IntLiteral = int_value 32 [concrete]
// CHECK:STDOUT:   %i32: type = class_type @Int, @Int(%int_32) [concrete]
// CHECK:STDOUT:   %ptr.6f5: type = ptr_type %Value [concrete]
// CHECK:STDOUT:   %operator_Plus__carbon_thunk.type: type = fn_type @operator_Plus__carbon_thunk [concrete]
// CHECK:STDOUT:   %operator_Plus__carbon_thunk: %operator_Plus__carbon_thunk.type = struct_value () [concrete]
// CHECK:STDOUT: }
// CHECK:STDOUT:
// CHECK:STDOUT: imports {
// CHECK:STDOUT:   %operator_Plus__carbon_thunk.decl: %operator_Plus__carbon_thunk.type = fn_decl @operator_Plus__carbon_thunk [concrete = constants.%operator_Plus__carbon_thunk] {
// CHECK:STDOUT:     <elided>
// CHECK:STDOUT:   } {
// CHECK:STDOUT:     <elided>
// CHECK:STDOUT:   }
// CHECK:STDOUT: }
// CHECK:STDOUT:
// CHECK:STDOUT: fn @Add(%left.param: %Value, %right.param: %Value) -> out %return.param: %i32 {
// CHECK:STDOUT: !entry:
// CHECK:STDOUT:   %left.ref: %Value = name_ref left, %left
// CHECK:STDOUT:   %right.ref: %Value = name_ref right, %right
// CHECK:STDOUT:   %.loc12_10: ref %Value = value_as_ref %left.ref
// CHECK:STDOUT:   %addr.loc12_15.1: %ptr.6f5 = addr_of %.loc12_10
// CHECK:STDOUT:   %.loc12_17: ref %Value = value_as_ref %right.ref
// CHECK:STDOUT:   %addr.loc12_15.2: %ptr.6f5 = addr_of %.loc12_17
// CHECK:STDOUT:   %operator_Plus__carbon_thunk.call: init %i32 = call imports.%operator_Plus__carbon_thunk.decl(%addr.loc12_15.1, %addr.loc12_15.2)
// CHECK:STDOUT:   return %operator_Plus__carbon_thunk.call
// CHECK:STDOUT: }
// CHECK:STDOUT:

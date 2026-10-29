// Part of the Carbon Language project, under the Apache License v2.0 with LLVM
// Exceptions. See /LICENSE for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// INCLUDE-FILE: toolchain/testing/testdata/min_prelude/full.carbon
//
// AUTOUPDATE
// TIP: To test this file alone, run:
// TIP:   bazel test //toolchain/testing:file_test --test_arg=--file_tests=toolchain/check/testdata/interop/cpp/operators/deduced_return.carbon
// TIP: To dump output, run:
// TIP:   bazel run //toolchain/testing:file_test -- --dump_output --file_tests=toolchain/check/testdata/interop/cpp/operators/deduced_return.carbon

// --- scalar.carbon

library "[[@TEST_NAME]]";

import Cpp inline '''
struct Value { int value; };
template<typename T> auto operator+(T left, T right) {
  return left.value + right.value;
}
''';

fn Add(left: Cpp.Value, right: Cpp.Value) -> i32 {
  //@dump-sem-ir-begin
  return left + right;
  //@dump-sem-ir-end
}

// CHECK:STDOUT: --- scalar.carbon
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
// CHECK:STDOUT:   %.loc13_10: ref %Value = value_as_ref %left.ref
// CHECK:STDOUT:   %addr.loc13_15.1: %ptr.6f5 = addr_of %.loc13_10
// CHECK:STDOUT:   %.loc13_17: ref %Value = value_as_ref %right.ref
// CHECK:STDOUT:   %addr.loc13_15.2: %ptr.6f5 = addr_of %.loc13_17
// CHECK:STDOUT:   %operator_Plus__carbon_thunk.call: init %i32 = call imports.%operator_Plus__carbon_thunk.decl(%addr.loc13_15.1, %addr.loc13_15.2)
// CHECK:STDOUT:   return %operator_Plus__carbon_thunk.call
// CHECK:STDOUT: }
// CHECK:STDOUT:

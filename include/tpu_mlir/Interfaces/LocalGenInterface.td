//===----------------------------------------------------------------------===//
//
// Copyright (c) 2020-2030 by Sophgo Technologies Inc. All rights reserved.
//
// Licensed under the Apache License v2.0.
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#ifndef TPU_MLIR_LOCAL_CODEGEN_INTERFACE
#define TPU_MLIR_LOCAL_CODEGEN_INTERFACE

include "mlir/IR/OpBase.td"

def LocalGenInterface : OpInterface<"LocalGenInterface"> {
  let description = [{
  }];
  let cppNamespace = "::tpu_mlir";
  let methods = [
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"::mlir::LogicalResult",
        /*methodName=*/"LocalGenSupport",
        /*args=*/(ins),
        /*methodBody=*/"",
        /*defaultImplementation=*/[{
          return mlir::success();
        }]
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"void",
        /*methodName=*/"codegen_local_int8_bm1684",
        /*args=*/(ins "int64_t":$n_step, "int64_t":$h_step)
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"void",
        /*methodName=*/"codegen_local_int8_bm1684x",
        /*args=*/(ins "int64_t":$n_step, "int64_t":$h_step)
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"void",
        /*methodName=*/"codegen_local_float_bm1684x",
        /*args=*/(ins "int64_t":$n_step, "int64_t":$h_step)
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"void",
        /*methodName=*/"codegen_local",
        /*args=*/(ins "int64_t":$n_step, "int64_t":$h_step),
        [{}],
        [{
          auto module = Module::getModuleOp($_op);
          auto chip = Module::getChip(module);
          auto type = Module::getStorageType($_op.getResult());
          if (chip == Module::Chip::BM1684) {
            $_op.codegen_local_int8_bm1684(n_step, h_step);
          } else if (chip == Module::Chip::BM1684x) {
            if (type.isF32() || type.isBF16() || type.isF16()) {
              $_op.codegen_local_float_bm1684x(n_step, h_step);
            } else {
              $_op.codegen_local_int8_bm1684x(n_step, h_step);
            }
          }
        }]
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"::mlir::LogicalResult",
        /*methodName=*/"BackwardH",
        /*args=*/(ins "int64_t&":$in_idx, "int64_t&":$in_slice, "int64_t":$out_idx, "int64_t":$out_slice),
        /*methodBody=*/"",
        /*defaultImplementation=*/[{
          in_idx = out_idx;
          in_slice = out_slice;
          return mlir::success();
        }]
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"::mlir::LogicalResult",
        /*methodName=*/"BackwardN",
        /*args=*/(ins "int64_t&":$in_idx, "int64_t&":$in_slice, "int64_t":$out_idx, "int64_t":$out_slice),
        /*methodBody=*/"",
        /*defaultImplementation=*/[{
          in_idx = out_idx;
          in_slice = out_slice;
          return mlir::success();
        }]
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"tpu_mlir::group_info_t",
        /*methodName=*/"getGroupInfo",
        /*args=*/(ins "int64_t":$n_step, "int64_t":$h_step),
        /*methodBody=*/"",
        /*defaultImplementation=*/[{
          return LocalGenInterface::getGroupInfo(this->getOperation(), n_step, h_step);
        }]
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"int64_t",
        /*methodName=*/"getBufferSize_bm1684",
        /*args=*/(ins "int64_t":$in_lmem_bytes, "int64_t":$out_lmem_bytes,
                      "int64_t":$in_nslice, "int64_t":$in_hslice,
                      "int64_t":$out_nslice, "int64_t":$out_hslice)
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"int64_t",
        /*methodName=*/"getBufferSize_bm1684x",
        /*args=*/(ins "int64_t":$in_lmem_bytes, "int64_t":$out_lmem_bytes,
                      "int64_t":$in_nslice, "int64_t":$in_hslice,
                      "int64_t":$out_nslice, "int64_t":$out_hslice)
      >,
      InterfaceMethod<
        /*desc=*/[{}],
        /*retType=*/"int64_t",
        /*methodName=*/"getBufferSize",
        /*args=*/(ins "int64_t":$in_lmem_bytes, "int64_t":$out_lmem_bytes,
                      "int64_t":$in_nslice, "int64_t":$in_hslice,
                      "int64_t":$out_nslice, "int64_t":$out_hslice),
        [{}],
        [{
          auto module = Module::getModuleOp($_op);
          auto chip = Module::getChip(module);
          if (chip == Module::Chip::BM1684) {
            return $_op.getBufferSize_bm1684(in_lmem_bytes, out_lmem_bytes,
                                             in_nslice, in_hslice, out_nslice, out_hslice);
          } else if (chip == Module::Chip::BM1684x) {
            return $_op.getBufferSize_bm1684x(in_lmem_bytes, out_lmem_bytes,
                                              in_nslice, in_hslice, out_nslice, out_hslice);
          }
          return 0;
        }]
      >,
  ];
  let extraClassDeclaration = [{
  static constexpr llvm::StringRef kLayerGroupAttrName = "group_info";
  static void fixSlice(int64_t &in_idx, int64_t &in_slice, int64_t in_length);
  static tpu_mlir::group_info_t getGroupInfo(mlir::Operation * op, int64_t n_step = 0, int64_t h_step = 0);
  static tpu_mlir::group_info_t getGroupInfo(mlir::Value, int64_t n_step = 0, int64_t h_step = 0);
  }];
}
#endif // TPU_MLIR_LOCAL_CODEGEN_INTERFACE

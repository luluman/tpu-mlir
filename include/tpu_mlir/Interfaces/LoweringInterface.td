//===----------------------------------------------------------------------===//
//
// Copyright (c) 2020-2030 by Sophgo Technologies Inc. All rights reserved.
//
// Licensed under the Apache License v2.0.
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#ifndef TPU_MLIR_LOWERINGINTERFACE
#define TPU_MLIR_LOWERINGINTERFACE

include "mlir/IR/OpBase.td"

def LoweringInterface : OpInterface<"LoweringInterface"> {
  let description = [{
  }];
  let cppNamespace = "::tpu_mlir";
  let methods = [
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_int8_bm1684",
        /*args=*/(ins)
      >,
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_f32_bm1684",
        /*args=*/(ins)
      >,
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_int8_bm1684x",
        /*args=*/(ins "bool":$asymmetric)
      >,
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_quant_bm1684x",
        /*args=*/(ins)
      >,
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_f32_bm1684x",
        /*args=*/(ins)
      >,
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_f16_bm1684x",
        /*args=*/(ins)
      >,
      InterfaceMethod<
        /*desc=*/[{
        }],
        /*retType=*/"mlir::Value",
        /*methodName=*/"lowering_bf16_bm1684x",
        /*args=*/(ins)
      >,
      ];

}
#endif // TPU_MLIR_LOWERINGINTERFACE

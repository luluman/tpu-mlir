//===----------------------------------------------------------------------===//
//
// Copyright (c) 2020-2030 by Sophgo Technologies Inc. All rights reserved.
//
// Licensed under the Apache License v2.0.
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#include "tpu_mlir/Dialect/Tpu/IR/TpuOps.h"
#include "tpu_mlir/Support/Dnnl/Dnnl.h"
#include "tpu_mlir/Support/Helper/Quant.h"
#include "tpu_mlir/Support/Helper/Module.h"
#include "tpu_mlir/Support/MathUtils.h"
#include "tpu_mlir/Support/Float16.h"

using namespace tpu_mlir;
using namespace tpu_mlir::helper;
using namespace mlir;

void tpu::MatMulOp::parseParam(int64_t &batch, int64_t &M, int64_t &K,
                               int64_t &N, bool &with_bias, bool &relu,
                               float &relu_upper_limit) {
  auto i_s = input().getType().cast<RankedTensorType>().getShape();
  auto r_s = right().getType().cast<RankedTensorType>().getShape();
  auto o_s = output().getType().cast<RankedTensorType>().getShape();
  with_bias = !bias().getType().isa<mlir::NoneType>();
  relu = do_relu();
  relu_upper_limit = this->upper_limit() == ::llvm::None ?
                     0.0 : this->upper_limitAttr().getValueAsDouble();
  auto r_dims = r_s.size();
  auto i_dims = i_s.size();
  N = r_s[r_dims - 1];
  K = r_s[r_dims - 2];
  if (r_dims > 2) {
    M = i_s[i_dims - 2];
    assert(i_s[i_dims - 1] == K);
    batch = std::accumulate(r_s.begin(), r_s.begin() + r_dims - 2, 1,
                            std::multiplies<int64_t>());
  } else {
    batch = 1;
    M = std::accumulate(i_s.begin(), i_s.begin() + i_dims - 1, 1,
                        std::multiplies<int64_t>());
  }
}

LogicalResult tpu::MatMulOp::init(InferenceParameter &p) {
  auto matmul = new MatMul();
  int64_t batch, M, K, N;
  bool relu, with_bias;
  float relu_upper_limit;
  parseParam(batch, M, K, N, with_bias, relu, relu_upper_limit);

  matmul->setup(p.inputs[0], p.inputs[1], p.inputs[2], p.outputs[0], batch, M,
                K, N, relu, relu_upper_limit);
  p.handle = (void *)matmul;
  return success();
}

void tpu::MatMulOp::deinit(InferenceParameter &p) {
  if (p.handle != nullptr) {
    auto matmul = (MatMul *)p.handle;
    delete matmul;
    p.handle = nullptr;
  }
  return;
}

LogicalResult tpu::MatMulOp::inference(InferenceParameter &p) {
  if (p.handle == nullptr) {
    return failure();
  }
  auto matmul = (MatMul *)p.handle;
  matmul->run();
  auto out_type = Module::getStorageType(output());
  auto num_elem = Module::getNumElements(output());
  if (out_type.isa<FloatType>()) {
    if (out_type.isBF16()) {
      f32_to_bf16(p.outputs[0], p.outputs[0], num_elem);
    } else if (out_type.isF16()) {
      f32_to_f16(p.outputs[0], p.outputs[0], num_elem);
    }
  } else if (Quant::isUniformQuantized(output())) {
    auto o_qtype = Quant::getUniformQuantizedType(output());
    auto rft = rshift();
    auto mlti = multiplier();
    auto num_output = Module::getNumElements(output());
#pragma omp parallel for schedule(static, omp_schedule(num_output))
    for (int64_t i = 0; i < num_output; i++) {
      auto v = (((int64_t)(p.outputs[0][i] * mlti) + (1 << (rft - 1))) >> rft);
      if (out_type.isUnsignedInteger(8)) {
        p.outputs[0][i] = Quant::to_uint8(v + o_qtype.getZeroPoint());
      } else {
        p.outputs[0][i] = Quant::to_int8(v + o_qtype.getZeroPoint());
      }
    }
  }

  return success();
}

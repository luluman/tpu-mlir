//===----------------------------------------------------------------------===//
//
// Copyright (c) 2020-2030 by Sophgo Technologies Inc. All rights reserved.
//
// Licensed under the Apache License v2.0.
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#include "tpu_mlir/Dialect/Top/IR/TopOps.h"
#include "tpu_mlir/Support/Dnnl/Dnnl.h"
#include "tpu_mlir/Support/Helper/Module.h"
#include "tpu_mlir/Support/MathUtils.h"

using namespace tpu_mlir;
using namespace tpu_mlir::helper;
using namespace mlir;

int64_t top::LeakyReluOp::getFLOPs() {
  return Module::getNumElements(output());
}

LogicalResult top::LeakyReluOp::init(InferenceParameter &p) {
  return success();
}
void top::LeakyReluOp::deinit(InferenceParameter &p) {}

LogicalResult top::LeakyReluOp::inference(InferenceParameter &p) {
  const float *src = p.inputs[0];
  float *dst = p.outputs[0];
  int64_t num_elements = Module::getNumElements(input());
#pragma omp parallel for schedule(static, omp_schedule(num_elements))
  for (int64_t i = 0; i < num_elements; ++i) {
    dst[i] = src[i] > 0
            ? src[i]
            : (static_cast<float>(alphaAttr().getValueAsDouble()) * src[i]);
  }
  return success();
}

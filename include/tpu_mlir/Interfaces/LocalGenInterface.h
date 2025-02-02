//===----------------------------------------------------------------------===//
//
// Copyright (c) 2020-2030 by Sophgo Technologies Inc. All rights reserved.
//
// Licensed under the Apache License v2.0.
// See http://www.apache.org/licenses/LICENSE-2.0 for license information.
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#pragma once

#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Operation.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"

namespace tpu_mlir {
typedef struct {
  int64_t out_addr;
  int64_t out_size;
  int64_t buffer_addr;
  int64_t buffer_size;
  int64_t n_idx;
  int64_t n_slice;
  int64_t h_idx;
  int64_t h_slice;
  int64_t timestep;
  bool eu_align;
  bool overstepped;
} group_info_t;
} // namespace tpu_mlir

#include "tpu_mlir/Support/Helper/Module.h"
using namespace tpu_mlir::helper;

/// Include the ODS generated interface header files.
#include "tpu_mlir/Interfaces/LocalGenInterface.h.inc"

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
#include "tpu_mlir/Support/Helper/Module.h"

#include <numeric>

using namespace mlir;
using namespace tpu_mlir;
using namespace tpu_mlir::top;
using namespace tpu_mlir::helper;

//===----------------------------------------------------------------------===//
// Dialect initialize method.
//===----------------------------------------------------------------------===//
#include "tpu_mlir/Dialect/Top/IR/TopOpsDialect.cpp.inc"
#include "tpu_mlir/Dialect/Top/IR/TopAttr.cpp.inc"

void TopDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "tpu_mlir/Dialect/Top/IR/TopOps.cpp.inc"
      >();
  wFile = nullptr;
}

//===----------------------------------------------------------------------===//
// Top Operator Definitions.
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "tpu_mlir/Dialect/Top/IR/TopOps.cpp.inc"

#include "sophgo/Dialect/Top/IR/TopOps.h"

#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace sophgo::top;

static bool supportFuseRelu(Operation *op) {
  if (isa<ConvOp, MaxPoolOp, AvgPoolOp, MatMulOp, AddOp>(op)) {
    return true;
  }
  return false;
}

struct TopFuseRelu : public OpRewritePattern<ReluOp> {
  using OpRewritePattern::OpRewritePattern;

  LogicalResult matchAndRewrite(ReluOp op,
                                PatternRewriter &rewriter) const override {
    auto formerOp = op.input().getDefiningOp();
    if (!formerOp->getResult(0).hasOneUse())
      return failure();

    if (false == supportFuseRelu(formerOp)) {
      return failure();
    }

    formerOp->setAttr("do_relu", rewriter.getBoolAttr(true));
    formerOp->setAttr("name", op.nameAttr());
    // remove the relu Op
    rewriter.replaceOp(op, {op.input()});
    return success();
  }
};

void ReluOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                         MLIRContext *context) {
  results.insert<TopFuseRelu>(context);
}

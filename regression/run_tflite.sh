#!/bin/bash
set -ex

INPUT=../resnet50_in_f32_b4.npz

mkdir -p tmp
pushd tmp
model_transform.py \
    --model_type tflite \
    --model_name resnet50 \
    --model_def  ../resnet50_quant_int8.tflite \
    --input_shapes [[4,3,224,224]] \
    --mlir resnet50_tflite.mlir

#########################
# TFLite to TPU BM1684x
#########################
tpuc-opt resnet50_tflite.mlir \
    --toptflite-to-tpu \
    --canonicalize \
    --save-weight \
    -o resnet50_int8_1684x.mlir

#########################
# TFLiteTPU BM1684x check
#########################
model_runner.py \
    --model resnet50_int8_1684x.mlir \
    --input $INPUT \
    --dump_all_tensors \
    --output resnet50_int8_outputs_1684x.npz


model_runner.py \
    --model ../resnet50_quant_int8.tflite \
    --input $INPUT \
    --dump_all_tensors \
    --output resnet50_ref_outputs.npz

npz_tool.py compare \
    resnet50_int8_outputs_1684x.npz \
    resnet50_ref_outputs.npz \
    --tolerance 0.89,0.50 -v

popd

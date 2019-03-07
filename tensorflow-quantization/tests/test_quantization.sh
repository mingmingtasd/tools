#
# Copyright (c) 2019 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: EPL-2.0
#

#!/usr/bin/env bash

echo 'Running with parameters:'
echo "    WORKSPACE: ${WORKSPACE}"
echo "    TF_WORKSPACE: ${TF_WORKSPACE}"
echo "    TEST_WORKSPACE: ${TEST_WORKSPACE}"
echo "        ${PRE_TRAINED_MODEL_DIR} mounted on: ${MOUNT_OUTPUT}"

# output directory for tests
OUTPUT=${MOUNT_OUTPUT}

function test_ouput_graph(){
    test -f ${OUTPUT_GRAPH}
}

# model quantization steps
function run_quantize_model_test(){

    # Get the dynamic range int8 graph
    cd ${TF_WORKSPACE}
    python tensorflow/tools/quantization/quantize_graph.py \
    --input=${FP32_MODEL} \
    --output=${OUTPUT}/${model}_int8_dynamic_range_graph.pb \
    --output_node_names=${OUTPUT_NODES} \
    --mode=eightbit \
    --intel_cpu_eightbitize=True

    OUTPUT_GRAPH=${OUTPUT}/${model}_int8_dynamic_range_graph.pb test_ouput_graph

    # Generate graph with logging
    bazel-bin/tensorflow/tools/graph_transforms/transform_graph \
    --in_graph=/${OUTPUT}/${model}_int8_dynamic_range_graph.pb \
    --out_graph=${OUTPUT}/${model}_int8_logged_graph.pb \
    --transforms="${TRANSFORMS1}"

    OUTPUT_GRAPH=${OUTPUT}/${model}_int8_logged_graph.pb test_ouput_graph

    # Convert the dynamic range int8 graph to freezed range graph
    bazel-bin/tensorflow/tools/graph_transforms/transform_graph \
    --in_graph=/${OUTPUT}/${model}_int8_dynamic_range_graph.pb \
    --out_graph=${OUTPUT}/${model}_int8_freezedrange_graph.pb \
    --transforms="${TRANSFORMS2}"

    OUTPUT_GRAPH=${OUTPUT}/${model}_int8_freezedrange_graph.pb test_ouput_graph

    # Generate the an optimized final int8 graph
    bazel-bin/tensorflow/tools/graph_transforms/transform_graph \
    --in_graph=${OUTPUT}/${model}_int8_freezedrange_graph.pb \
    --outputs=${OUTPUT_NODES} \
    --out_graph=${OUTPUT}/${model}_int8_final_fused_graph.pb \
    --transforms="${TRANSFORMS3}"

    OUTPUT_GRAPH=${OUTPUT}/${model}_int8_final_fused_graph.pb test_ouput_graph
}

function resnet50(){
    OUTPUT_NODES='predict'

    # Download the FP32 pre-trained model
    cd ${OUTPUT}
    wget https://storage.googleapis.com/intel-optimized-tensorflow/models/resnet50_fp32_pretrained_model.pb
    FP32_MODEL=${OUTPUT}/resnet50_fp32_pretrained_model.pb

    # to generate the logging graph
    TRANSFORMS1='insert_logging(op=RequantizationRange, show_name=true, message="__requant_min_max:")'

    # to freeze the dynamic range graph
    TRANSFORMS2='freeze_requantization_ranges(min_max_log_file="/workspace/tests/calibration_data/resnet50_min_max_log.txt")'

    # to get the fused and optimized final int8 graph
    TRANSFORMS3='fuse_quantized_conv_and_requantize strip_unused_nodes'

    run_quantize_model_test
}

# Run all models, when new model is added append model name below
for model in resnet50
do
    ${model}
done

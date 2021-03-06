# Description:
#   Utilities for quantizing TensorFlow graphs to lower bit depths.

package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

exports_files(["LICENSE"])

load("//tensorflow:tensorflow.bzl", "py_test")

py_library(
    name = "quantize_graph_lib",
    srcs = ["quantize_graph.py"],
    srcs_version = "PY2AND3",
    deps = [
        "//tensorflow/core:protos_all_py",
        "//tensorflow/python:array_ops",
        "//tensorflow/python:constant_op",
        "//tensorflow/python:dtypes",
        "//tensorflow/python:framework",
        "//tensorflow/python:framework_ops",
        "//tensorflow/python:graph_util",
        "//tensorflow/python:platform",
        "//tensorflow/python:session",
        "//tensorflow/python:tensor_shape",
        "//tensorflow/python:tensor_util",
        "//third_party/py/numpy",
    ],
)

py_binary(
    name = "quantize_graph",
    srcs = ["quantize_graph.py"],
    srcs_version = "PY2AND3",
    deps = [
        "//tensorflow/core:protos_all_py",
        "//tensorflow/python",  # TODO(b/34059704): remove when fixed
        "//tensorflow/python:array_ops",
        "//tensorflow/python:client",
        "//tensorflow/python:framework",
        "//tensorflow/python:framework_for_generated_wrappers",
        "//tensorflow/python:graph_util",
        "//tensorflow/python:platform",
        "//tensorflow/python:tensor_util",
        "//third_party/py/numpy",
    ],
)

py_test(
    name = "quantize_graph_test",
    size = "small",
    srcs = ["quantize_graph_test.py"],
    srcs_version = "PY2AND3",
    tags = ["nomsan"],  # http://b/32242946
    deps = [
        ":quantize_graph",
        "//tensorflow/core:protos_all_py",
        "//tensorflow/python:client",
        "//tensorflow/python:client_testlib",
        "//tensorflow/python:framework",
        "//tensorflow/python:framework_for_generated_wrappers",
        "//tensorflow/python:graph_util",
        "//tensorflow/python:platform",
        "//third_party/py/numpy",
    ],
)

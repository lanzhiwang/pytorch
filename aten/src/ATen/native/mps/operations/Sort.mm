//  Copyright © 2023 Apple Inc.
#define TORCH_ASSERT_ONLY_METHOD_OPERATORS
#include <ATen/MemoryOverlap.h>
#include <ATen/WrapDimUtils.h>
#include <ATen/native/TensorShape.h>
#include <ATen/native/TypeProperties.h>
#include <ATen/native/mps/MPSGraphVenturaOps.h>
#include <ATen/native/mps/OperationUtils.h>

#ifndef AT_PER_OPERATOR_HEADERS
#include <ATen/Functions.h>
#include <ATen/NativeFunctions.h>
#else
#include <ATen/ops/sort.h>
#include <ATen/ops/sort_native.h>
#endif
namespace at::native {

// sort
TORCH_IMPL_FUNC(sort_stable_out_mps)
(const Tensor& self,
 c10::optional<bool> stable,
 int64_t dim,
 bool descending,
 const Tensor& values,
 const Tensor& indices) {
  using namespace mps;

  bool macOS13_3_plus = is_macos_13_or_newer(MacOSVersion::MACOS_VER_13_3_PLUS);
  MPS_CHECK_INT64_OP_SUPPORTED(self, macOS13_3_plus, "sort_stable_out");


  // issue #101878: MPS might give a wrong sorted tensor when dealing with a strided view tensor.
  // create a proxy tensor to temporarily address the issue
  Tensor input_contiguous = self.contiguous();
  Tensor values_contiguous = self.contiguous();

  // check if input_contiguous is scalar
  dim = maybe_wrap_dim(dim, input_contiguous.dim(), true);
  if (input_contiguous.dim() == 0 && input_contiguous.numel() == 1) {
    indices.zero_();
    return;
  }

  if (!is_macos_13_or_newer()) {
    TORCH_WARN_ONCE("torch.sort is supported by MPS on MacOS 13+, please upgrade. Falling back to CPU");
    Tensor cpu_indices = indices.clone().to("cpu");
    Tensor cpu_values = values.clone().to("cpu");
    at::sort_out(cpu_values, cpu_indices, input_contiguous.to(at::Device(kCPU)), false, dim, descending);
    values.copy_(cpu_values);
    indices.copy_(cpu_indices);
    return;
  }

  MPSStream* stream = getCurrentMPSStream();
  struct CachedGraph : public MPSCachedGraph {
    CachedGraph(MPSGraph* graph) : MPSCachedGraph(graph) {}
    MPSGraphTensor *selfTensor = nil, *valuesTensor = nil, *indicesTensor = nil;
  };
  @autoreleasepool {
    // Input as placeholders
    MPSShape* input_shape = getMPSShape(input_contiguous);
    NSString* ns_shape_key = [[input_shape valueForKey:@"description"] componentsJoinedByString:@","];
    string key = string("sort:") + [ns_shape_key UTF8String] + ":" + getMPSTypeString(input_contiguous) + ":dim" + to_string(dim) +
        ":descending" + to_string(descending);
    auto cachedGraph = LookUpOrCreateCachedGraph<CachedGraph>(key, [&](auto mpsGraph, auto newCachedGraph) {
      newCachedGraph->selfTensor = mpsGraphRankedPlaceHolder(mpsGraph, getMPSDataType(input_contiguous), input_shape);

      MPSGraphTensor* castInputTensor =
          castToIHFTypes(mpsGraph, newCachedGraph->selfTensor, input_contiguous, /*includesInt64=*/macOS13_3_plus);
      MPSGraphTensor* sortedTensor = [mpsGraph sortWithTensor:castInputTensor
                                                         axis:(NSInteger)dim
                                                   descending:(BOOL)descending
                                                         name:@"sort_out"];
      if ([sortedTensor dataType] != getMPSDataType(values_contiguous)) {
        sortedTensor = castMPSTensor(mpsGraph, sortedTensor, values_contiguous.scalar_type());
      }
      MPSGraphTensor* argSortedTensor = [mpsGraph argSortWithTensor:castInputTensor
                                                               axis:(NSInteger)dim
                                                         descending:(BOOL)descending
                                                               name:@"argsort_out"];
      if ([argSortedTensor dataType] != getMPSDataType(indices)) {
        argSortedTensor = castMPSTensor(mpsGraph, argSortedTensor, indices.scalar_type());
      }
      newCachedGraph->valuesTensor = sortedTensor;
      newCachedGraph->indicesTensor = argSortedTensor;
    });
    Placeholder inputPlaceholder = Placeholder(cachedGraph->selfTensor, input_contiguous);
    // Outputs as placeholders
    Placeholder valuesPlaceholder = Placeholder(cachedGraph->valuesTensor, values_contiguous);
    Placeholder indicesPlaceholder = Placeholder(cachedGraph->indicesTensor, indices);
    // Create dictionary of inputs and outputs
    NSDictionary<MPSGraphTensor*, MPSGraphTensorData*>* feeds = nil;
    feeds = @{inputPlaceholder.getMPSGraphTensor() : inputPlaceholder.getMPSGraphTensorData()};
    NSDictionary<MPSGraphTensor*, MPSGraphTensorData*>* results = @{
      valuesPlaceholder.getMPSGraphTensor() : valuesPlaceholder.getMPSGraphTensorData(),
      indicesPlaceholder.getMPSGraphTensor() : indicesPlaceholder.getMPSGraphTensorData()
    };

    runMPSGraph(stream, cachedGraph->graph(), feeds, results);
  }

  // Copy the sorted values back to values
  values.copy_(values_contiguous);
}
}

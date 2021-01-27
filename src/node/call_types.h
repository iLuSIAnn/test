// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the Apache 2.0 License.
#pragma once
#include "enclave/interface.h"

namespace ccf
{
  struct CreateNew
  {
    struct In
    {
      StartType start_type;
      CCFConfig config;
    };
    struct Out
    {
      tls::Pem node_cert;
      tls::Pem network_cert;
    };
  };
}

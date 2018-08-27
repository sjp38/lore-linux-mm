Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB2F46B3F64
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 03:55:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k17-v6so814489pll.21
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 00:55:40 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j5-v6si13565094plk.406.2018.08.27.00.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 00:55:39 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH 0/3] swap: Code refactoring for some swap free related functions
Date: Mon, 27 Aug 2018 15:55:32 +0800
Message-Id: <20180827075535.17406-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

To improve the code readability.  Some swap free related functions are refactored.

This patchset is based on 8/23 HEAD of mmotm tree.

Best Regards,
Huang, Ying

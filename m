Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA7086B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 17:44:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u5so7739558wmg.13
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 14:44:05 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p23si1185550edc.0.2017.04.25.14.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 14:44:04 -0700 (PDT)
Date: Tue, 25 Apr 2017 17:43:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v10 2/3] mm, THP, swap: Check whether THP can be
 split firstly
Message-ID: <20170425214357.GA6841@cmpxchg.org>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-3-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170425125658.28684-3-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 25, 2017 at 08:56:57PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> To swap out THP (Transparent Huage Page), before splitting the THP,
> the swap cluster will be allocated and the THP will be added into the
> swap cache.  But it is possible that the THP cannot be split, so that
> we must delete the THP from the swap cache and free the swap cluster.
> To avoid that, in this patch, whether the THP can be split is checked
> firstly.  The check can only be done racy, but it is good enough for
> most cases.
> 
> With the patch, the swap out throughput improves 3.6% (from about
> 4.16GB/s to about 4.31GB/s) in the vm-scalability swap-w-seq test case
> with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
> device used is a RAM simulated PMEM (persistent memory) device.  To
> test the sequential swapping out, the test case creates 8 processes,
> which sequentially allocate and write to the anonymous pages until the
> RAM and part of the swap device is used up.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for can_split_huge_page()]

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

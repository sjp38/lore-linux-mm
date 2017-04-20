Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20A276B03B2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 16:50:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v52so6846948wrb.14
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:50:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k88si11020844wrc.30.2017.04.20.13.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 13:50:42 -0700 (PDT)
Date: Thu, 20 Apr 2017 16:50:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v9 2/3] mm, THP, swap: Check whether THP can be
 split firstly
Message-ID: <20170420205035.GA13229@cmpxchg.org>
References: <20170419070625.19776-1-ying.huang@intel.com>
 <20170419070625.19776-3-ying.huang@intel.com>
 <20170419161318.GC3376@cmpxchg.org>
 <87efwnrjfg.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87efwnrjfg.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 20, 2017 at 08:50:43AM +0800, Huang, Ying wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
> > On Wed, Apr 19, 2017 at 03:06:24PM +0800, Huang, Ying wrote:
> >> With the patchset, the swap out throughput improves 3.6% (from about
> >> 4.16GB/s to about 4.31GB/s) in the vm-scalability swap-w-seq test case
> >> with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
> >> device used is a RAM simulated PMEM (persistent memory) device.  To
> >> test the sequential swapping out, the test case creates 8 processes,
> >> which sequentially allocate and write to the anonymous pages until the
> >> RAM and part of the swap device is used up.
> >> 
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> >> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for can_split_huge_page()]
> >
> > How often does this actually happen in practice? Because all that this
> > protects us from is trying to allocate a swap cluster - which with the
> > si->free_clusters list really isn't all that expensive - and return it
> > again. Unless this happens all the time in practice, this optimization
> > seems misplaced.
>
> To my surprise too, I found this patch has measurable impact in my
> test.  The swap out throughput improves 3.6% in the vm-scalability
> swap-w-seq test case with 8 processes.  Details are in the original
> patch description.

Yeah I think that justifies it.

The changelog says "the patchset", I didn't realize this is the gain
from just this patch alone. Care to update that?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

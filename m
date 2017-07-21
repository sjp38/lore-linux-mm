Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF096B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:22:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u89so18417146wrc.1
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 16:22:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k96si8764519wrc.309.2017.07.21.16.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 16:21:32 -0700 (PDT)
Date: Fri, 21 Jul 2017 16:21:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v2 00/12] mm, THP, swap: Delay splitting THP after
 swapped out
Message-Id: <20170721162129.077f7d9b4c77c8593e47aed9@linux-foundation.org>
In-Reply-To: <20170623071303.13469-1-ying.huang@intel.com>
References: <20170623071303.13469-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Ming Lei <ming.lei@redhat.com>

On Fri, 23 Jun 2017 15:12:51 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
> 
> Hi, Johannes and Minchan, Thanks a lot for your review to the first
> step of the THP swap optimization!  Could you help me to review the
> second step in this patchset?
> 
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [01/12], [02/12], [03/12],
> [04/12], [11/12], and [12/12].
> 
> Hi, Andrea and Kirill, could you help me to review the THP part of the
> patchset?  Especially [01/12], [03/12], [07/12], [08/12], [09/12],
> [11/12].
> 
> Hi, Johannes, Michal, could you help me to review the cgroup part of
> the patchset?  Especially [08/12], [09/12], and [10/12].
> 
> And for all, Any comment is welcome!

I guess it's time for a resend.  Folks, could we please get some more
review&test going here?

> Because the THP swap writing support patch [06/12] needs to be rebased
> on multipage bvec patchset which hasn't been merged yet.  The [06/12]
> in this patchset is just a test patch and will be rewritten later.
> The patchset depends on multipage bvec patchset too.

Are these dependency issues any simpler now?

> This is the second step of THP (Transparent Huge Page) swap
> optimization.  In the first step, the splitting huge page is delayed
> from almost the first step of swapping out to after allocating the
> swap space for the THP and adding the THP into the swap cache.  In the
> second step, the splitting is delayed further to after the swapping
> out finished.  The plan is to delay splitting THP step by step,
> finally avoid splitting THP for the THP swapping out and swap out/in
> the THP as a whole.
> 
> In the patchset, more operations for the anonymous THP reclaiming,
> such as TLB flushing, writing the THP to the swap device, removing the
> THP from the swap cache are batched.  So that the performance of
> anonymous THP swapping out are improved.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

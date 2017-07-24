Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1D16B0292
	for <linux-mm@kvack.org>; Sun, 23 Jul 2017 20:57:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k72so13990844pfj.1
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 17:57:54 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id v11si1226223pfl.262.2017.07.23.17.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 17:57:53 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2 00/12] mm, THP, swap: Delay splitting THP after swapped out
References: <20170623071303.13469-1-ying.huang@intel.com>
	<20170721162129.077f7d9b4c77c8593e47aed9@linux-foundation.org>
Date: Mon, 24 Jul 2017 08:57:48 +0800
In-Reply-To: <20170721162129.077f7d9b4c77c8593e47aed9@linux-foundation.org>
	(Andrew Morton's message of "Fri, 21 Jul 2017 16:21:29 -0700")
Message-ID: <874lu2ircj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Ming Lei <ming.lei@redhat.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Fri, 23 Jun 2017 15:12:51 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Hi, Andrew, could you help me to check whether the overall design is
>> reasonable?
>> 
>> Hi, Johannes and Minchan, Thanks a lot for your review to the first
>> step of the THP swap optimization!  Could you help me to review the
>> second step in this patchset?
>> 
>> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
>> swap part of the patchset?  Especially [01/12], [02/12], [03/12],
>> [04/12], [11/12], and [12/12].
>> 
>> Hi, Andrea and Kirill, could you help me to review the THP part of the
>> patchset?  Especially [01/12], [03/12], [07/12], [08/12], [09/12],
>> [11/12].
>> 
>> Hi, Johannes, Michal, could you help me to review the cgroup part of
>> the patchset?  Especially [08/12], [09/12], and [10/12].
>> 
>> And for all, Any comment is welcome!
>
> I guess it's time for a resend.  Folks, could we please get some more
> review&test going here?

Sure.  Will resend it ASAP.  And Thanks for reminding!

>> Because the THP swap writing support patch [06/12] needs to be rebased
>> on multipage bvec patchset which hasn't been merged yet.  The [06/12]
>> in this patchset is just a test patch and will be rewritten later.
>> The patchset depends on multipage bvec patchset too.
>
> Are these dependency issues any simpler now?

Ming Lei has sent the v2 of multipage bvec patchset on June 26th.  Jens
Axboe thinks the patchset will target v4.14.

https://lkml.org/lkml/2017/6/26/538

Best Regards,
Huang, Ying

>> This is the second step of THP (Transparent Huge Page) swap
>> optimization.  In the first step, the splitting huge page is delayed
>> from almost the first step of swapping out to after allocating the
>> swap space for the THP and adding the THP into the swap cache.  In the
>> second step, the splitting is delayed further to after the swapping
>> out finished.  The plan is to delay splitting THP step by step,
>> finally avoid splitting THP for the THP swapping out and swap out/in
>> the THP as a whole.
>> 
>> In the patchset, more operations for the anonymous THP reclaiming,
>> such as TLB flushing, writing the THP to the swap device, removing the
>> THP from the swap cache are batched.  So that the performance of
>> anonymous THP swapping out are improved.
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

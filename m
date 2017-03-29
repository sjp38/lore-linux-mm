Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 050916B0397
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:52:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id a72so6894856pge.10
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:52:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r22si4824991pfr.302.2017.03.29.01.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 01:52:16 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v7 0/9] THP swap: Delay splitting THP during swapping out
References: <20170328053209.25876-1-ying.huang@intel.com>
	<20170328151358.80a14e40d1a431084bc27db4@linux-foundation.org>
Date: Wed, 29 Mar 2017 16:52:12 +0800
In-Reply-To: <20170328151358.80a14e40d1a431084bc27db4@linux-foundation.org>
	(Andrew Morton's message of "Tue, 28 Mar 2017 15:13:58 -0700")
Message-ID: <87shlwtqgz.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Hi, Andrew,

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 28 Mar 2017 13:32:00 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> Hi, Andrew, could you help me to check whether the overall design is
>> reasonable?
>> 
>> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
>> swap part of the patchset?  Especially [1/9], [3/9], [4/9], [5/9],
>> [6/9], [9/9].
>> 
>> Hi, Andrea could you help me to review the THP part of the patchset?
>> Especially [2/9], [7/9] and [8/9].
>> 
>> Hi, Johannes, Michal and Vladimir, I am not very confident about the
>> memory cgroup part, especially [2/9].  Could you help me to review it?
>> 
>> And for all, Any comment is welcome!
>> 
>> 
>> Recently, the performance of the storage devices improved so fast that
>> we cannot saturate the disk bandwidth with single logical CPU when do
>> page swap out even on a high-end server machine.  Because the
>> performance of the storage device improved faster than that of single
>> logical CPU.  And it seems that the trend will not change in the near
>> future.  On the other hand, the THP becomes more and more popular
>> because of increased memory size.  So it becomes necessary to optimize
>> THP swap performance.
>
> I'll merge this patchset for testing purposes, but I don't believe that
> it has yet had sufficient review.  And thanks for drawing our attention
> to those parts where you believe close review is needed - that helps.

Thanks a lot for your help!  I believe the patchset will be better
tested in -mm tree.  And hope people will have time to review it more
closely.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5CB6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 18:14:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 133so841897itu.17
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 15:14:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 24si5766629ioj.222.2017.03.28.15.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 15:14:00 -0700 (PDT)
Date: Tue, 28 Mar 2017 15:13:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v7 0/9] THP swap: Delay splitting THP during
 swapping out
Message-Id: <20170328151358.80a14e40d1a431084bc27db4@linux-foundation.org>
In-Reply-To: <20170328053209.25876-1-ying.huang@intel.com>
References: <20170328053209.25876-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Tue, 28 Mar 2017 13:32:00 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
> 
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [1/9], [3/9], [4/9], [5/9],
> [6/9], [9/9].
> 
> Hi, Andrea could you help me to review the THP part of the patchset?
> Especially [2/9], [7/9] and [8/9].
> 
> Hi, Johannes, Michal and Vladimir, I am not very confident about the
> memory cgroup part, especially [2/9].  Could you help me to review it?
> 
> And for all, Any comment is welcome!
> 
> 
> Recently, the performance of the storage devices improved so fast that
> we cannot saturate the disk bandwidth with single logical CPU when do
> page swap out even on a high-end server machine.  Because the
> performance of the storage device improved faster than that of single
> logical CPU.  And it seems that the trend will not change in the near
> future.  On the other hand, the THP becomes more and more popular
> because of increased memory size.  So it becomes necessary to optimize
> THP swap performance.

I'll merge this patchset for testing purposes, but I don't believe that
it has yet had sufficient review.  And thanks for drawing our attention
to those parts where you believe close review is needed - that helps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

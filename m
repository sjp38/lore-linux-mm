Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id ECEAD6B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 11:56:52 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so3153106qeb.25
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 08:56:52 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id b6si9395855qak.38.2013.12.15.08.56.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Dec 2013 08:56:49 -0800 (PST)
Date: Sun, 15 Dec 2013 17:56:43 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 1/4] sched/numa: drop
 sysctl_numa_balancing_settle_count sysctl
Message-ID: <20131215165643.GC16438@laptop.programming.kicks-ass.net>
References: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131213180933.GS21999@twins.programming.kicks-ass.net>
 <20131215084110.GA4316@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131215084110.GA4316@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 15, 2013 at 04:41:10PM +0800, Wanpeng Li wrote:
> Do you mean something like: 
> 
> commit 887c290e (sched/numa: Decide whether to favour task or group
> weights
> based on swap candidate relationships) drop the check against
> sysctl_numa_balancing_settle_count, this patch remove the sysctl.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
> Changelog:
>  v7 -> v8:
>    * remove references to it in Documentation/sysctl/kernel.txt
> ---

No need to insert another --- line, just the one below the SoB,

> Documentation/sysctl/kernel.txt |    5 -----
> include/linux/sched/sysctl.h    |    1 -
> kernel/sched/fair.c             |    9 ---------
> kernel/sysctl.c                 |    7 -------
> 4 files changed, 0 insertions(+), 22 deletions(-)

Everything between --- and the patch proper (usually started with an
Index line or other diff syntax thingy), including this diffstat you
have, will be made to disappear.

But yes indeed. The Changelog should describe the patch as is, and the
differences between this and the previous version are relevant only to
the reviewer who saw the previous version too. But once we commit the
patch, the previous version ceases to exist (in the commit history) and
therefore such comments loose their intrinsic meaning and should go away
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

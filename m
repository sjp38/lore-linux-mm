Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3C4900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:15:33 -0400 (EDT)
Received: by vxk20 with SMTP id 20so2569122vxk.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:15:32 -0700 (PDT)
Date: Fri, 15 Apr 2011 06:15:22 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110414211522.GE21397@mtj.dyndns.org>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
 <alpine.DEB.2.00.1104131148070.20908@router.home>
 <20110413185618.GA3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131521050.25812@router.home>
 <1302747263.3549.9.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104141608300.19533@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104141608300.19533@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello,

On Thu, Apr 14, 2011 at 04:10:34PM -0500, Christoph Lameter wrote:
> On Thu, 14 Apr 2011, Eric Dumazet wrote:
> 
> > Not sure its a win for my servers, where CONFIG_PREEMPT_NONE=y
> 
> Well the fast path would then also be irq safe. Does that bring us
> anything?
> 
> We could not do the cmpxchg in the !PREEMPT case and instead simply store
> the value.
> 
> The preempt on/off seems to be a bigger deal for realtime.

Also, the cmpxchg used is local one w/o LOCK prefix.  It might not
bring anything to table on !PREEMPT kernels but at the same time it
shouldn't hurt either.  One way or the other, some benchmark numbers
showing that it at least doesn't hurt would be nice.

> > Maybe use here latest cmpxchg16b stuff instead and get rid of spinlock ?
> 
> Shaohua already got an atomic in there. You mean get rid of his preempt
> disable/enable in the slow path?

I personally care much less about slow path.  According to Shaohua,
atomic64_t behaves pretty nice and it isn't too complex, so I'd like
to stick with that unless complex this_cpu ops can deliver something
much better.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 01A606B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:31:08 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2782831fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:31:05 -0700 (PDT)
Date: Thu, 28 Apr 2011 17:31:01 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428153101.GF16552@htj.dyndns.org>
References: <20110428100938.GA10721@htj.dyndns.org>
 <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280935460.16323@router.home>
 <20110428144446.GC16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280951480.16323@router.home>
 <20110428145657.GD16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281003000.16323@router.home>
 <20110428151203.GE16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281017240.16323@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104281017240.16323@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 10:22:19AM -0500, Christoph Lameter wrote:
> On Thu, 28 Apr 2011, Tejun Heo wrote:
> 
> > It seems like we can split hairs all day long about the similarities
> > and differences with atomics, so let's forget about atomics for now.
> 
> Ok good idea. So you accept that per cpu counters are inevitably fuzzy and
> that the result cannot be relied upon in the same way as on atomics?

No, I don't, at all.

> > I don't like any update having possibility of causing @batch jumps in
> > _sum() result.  That severely limits the usefulness of hugely
> > expensive _sum() and the ability to scale @batch.  Not everything in
> > the world is vmstat.  Think about other _CURRENT_ use cases in
> > filesystems.
> 
> Of course you can cause jumps > batch. You are looping over 8 cpus and
> have done cpu 1 and 2 already. Then cpu 1 adds batch-1 to the local per
> cpu counter. cpu 2 increments its per cpu counter. When _sum returns we
> have deviation of batch.
> 
> In the worst case the deviation can increase to (NR_CPUS - 1) * (batch
> -1). That is for the current code!!!
> 
> The hugely expensive _sum() is IMHO pretty useless given the above. It is
> a function that is called with the *hope* of getting a more accurate
> result.

No, it isn't.  It provides meaningful enough accuracy for many use
cases.  It is not about extreme limits on pathological cases.  It's
being reasonably accurate so that it doesn't deviate too much from
expectations arising from given level of update frequency and
concurrency.

Christoph, I'm sorry but I really can't explain it any better and am
out of this thread.  If you still wanna proceed, you'll need to route
the patches yourself.  Please keep me cc'd.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

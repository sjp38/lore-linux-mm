Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 729A16B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:12:10 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2763225fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 08:12:07 -0700 (PDT)
Date: Thu, 28 Apr 2011 17:12:03 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428151203.GE16552@htj.dyndns.org>
References: <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280935460.16323@router.home>
 <20110428144446.GC16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280951480.16323@router.home>
 <20110428145657.GD16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281003000.16323@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104281003000.16323@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 10:05:09AM -0500, Christoph Lameter wrote:
> On Thu, 28 Apr 2011, Tejun Heo wrote:
> > Gees, Christoph.  That is a test case to show the issue prominently,
> > which is what a test case is supposed to do.  What it means is that
> > _any_ update can trigger @batch deviation on _sum() regardless of its
> > frequency or concurrency level and that's the nastiness I've been
> > talking about over and over again.
> 
> As far as I understand it: This is a test case where you want to show us
> the atomic_t type behavior of _sum. This only works in such an artificial
> test case. In reality batches of updates will modify any 'accurate' result
> that you may have obtained from the _sum function.

It seems like we can split hairs all day long about the similarities
and differences with atomics, so let's forget about atomics for now.

I don't like any update having possibility of causing @batch jumps in
_sum() result.  That severely limits the usefulness of hugely
expensive _sum() and the ability to scale @batch.  Not everything in
the world is vmstat.  Think about other _CURRENT_ use cases in
filesystems.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A01C6B0022
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:05:13 -0400 (EDT)
Date: Thu, 28 Apr 2011 10:05:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110428145657.GD16552@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104281003000.16323@router.home>
References: <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe> <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe> <20110428100938.GA10721@htj.dyndns.org> <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org> <alpine.DEB.2.00.1104280935460.16323@router.home> <20110428144446.GC16552@htj.dyndns.org> <alpine.DEB.2.00.1104280951480.16323@router.home> <20110428145657.GD16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 28 Apr 2011, Tejun Heo wrote:

> Hey,
>
> On Thu, Apr 28, 2011 at 09:52:35AM -0500, Christoph Lameter wrote:
> > On Thu, 28 Apr 2011, Tejun Heo wrote:
> >
> > > Eh?  Are you saying the above can't happen or the above doesn't
> > > matter?
> >
> > Its an artificial use case that does not reflect the realities on how
> > these counters are typically used.
>
> Gees, Christoph.  That is a test case to show the issue prominently,
> which is what a test case is supposed to do.  What it means is that
> _any_ update can trigger @batch deviation on _sum() regardless of its
> frequency or concurrency level and that's the nastiness I've been
> talking about over and over again.

As far as I understand it: This is a test case where you want to show us
the atomic_t type behavior of _sum. This only works in such an artificial
test case. In reality batches of updates will modify any 'accurate' result
that you may have obtained from the _sum function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

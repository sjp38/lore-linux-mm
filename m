Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AAA55900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 04:52:17 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3459331fxm.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 01:52:13 -0700 (PDT)
Date: Fri, 29 Apr 2011 10:52:10 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110429085210.GK16552@htj.dyndns.org>
References: <20110428145657.GD16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281003000.16323@router.home>
 <20110428151203.GE16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104281017240.16323@router.home>
 <1304005726.3360.69.camel@edumazet-laptop>
 <1304006345.3360.72.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104281116270.18213@router.home>
 <1304008533.3360.88.camel@edumazet-laptop>
 <alpine.DEB.2.00.1104281152110.18213@router.home>
 <1304009996.5827.3.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1304009996.5827.3.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Shaohua Li <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 06:59:56PM +0200, Eric Dumazet wrote:
> Le jeudi 28 avril 2011 a 11:52 -0500, Christoph Lameter a ecrit :
> 
> > I can still add (batch - 1) without causing the seqcount to be
> > incremented.
> 
> It always had been like that, from the very beginning.

This doesn't matter.  At this level, the order of concurrent
operations is not well defined.  You might as well say "oh well, then
the update happened after the sum is calculated".

The problem I have with the interface are two-folds.

1. Is it even necessary?  With concurrent updates, we don't and can't
   define strict order of updates across multiple CPUs.  If we sweep
   the counters without being intervened (IRQ or, well, NMI), it
   should be and has been acceptable enough.

2. Let's say we need this.  Then, @maxfuzzy.  Few people are gonna
   understand it well and use it properly.  Why can't you track the
   actual deviation introduced since sum started instead of tracking
   the number of deviation events?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

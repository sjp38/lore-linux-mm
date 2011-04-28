Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA3C16B0023
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:57:03 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2745528fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 07:57:01 -0700 (PDT)
Date: Thu, 28 Apr 2011 16:56:57 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428145657.GD16552@htj.dyndns.org>
References: <20110426121011.GD878@htj.dyndns.org>
 <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280935460.16323@router.home>
 <20110428144446.GC16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280951480.16323@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104280951480.16323@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hey,

On Thu, Apr 28, 2011 at 09:52:35AM -0500, Christoph Lameter wrote:
> On Thu, 28 Apr 2011, Tejun Heo wrote:
> 
> > Eh?  Are you saying the above can't happen or the above doesn't
> > matter?
> 
> Its an artificial use case that does not reflect the realities on how
> these counters are typically used.

Gees, Christoph.  That is a test case to show the issue prominently,
which is what a test case is supposed to do.  What it means is that
_any_ update can trigger @batch deviation on _sum() regardless of its
frequency or concurrency level and that's the nastiness I've been
talking about over and over again.

For fast path, sure.  For slow path, I don't think so.  If the
tradeoff still doesn't make sense to you, I don't know how to persuade
you guys.  I'm not gonna take it.  You and Shaohua are welcome to go
over my head and send the changes to Andrew or Linus, but please keep
me cc'd so that I can voice my objection.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A62DB6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:46:13 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2731919fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 07:46:12 -0700 (PDT)
Date: Thu, 28 Apr 2011 16:44:46 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428144446.GC16552@htj.dyndns.org>
References: <20110421190807.GK15988@htj.dyndns.org>
 <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org>
 <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org>
 <alpine.DEB.2.00.1104280935460.16323@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104280935460.16323@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 09:42:49AM -0500, Christoph Lameter wrote:
> > > Can you show in some tests how the chance of deviations is increased? If
> > > at all then in some special sitations. Maybe others get better?
> >
> > It's kinda obvious, isn't it?  Do relatively low freq (say, every
> > 10ms) +1's and continuously do _sum().  Before, _sum() would never
> > deviate much from the real count.  After, there will be @batch jumps.
> > If you still need proof code, I would write it but please note that
> > I'm pretty backed up.
> 
> "Obvious" could mean that you are drawing conclusions without a proper
> reasoning chain. Here you assume certain things about the users of the
> counters. The same assumptions were made when we had the vm counter
> issues. The behavior of counter increments is typically not a regular
> stream but occurs in spurts.

Eh?  Are you saying the above can't happen or the above doesn't
matter?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1BB6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:30:23 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2713958fxm.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 07:30:20 -0700 (PDT)
Date: Thu, 28 Apr 2011 16:30:17 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110428143017.GB16552@htj.dyndns.org>
References: <alpine.DEB.2.00.1104211350310.5741@router.home>
 <20110421190807.GK15988@htj.dyndns.org>
 <1303439580.3981.241.camel@sli10-conroe>
 <20110426121011.GD878@htj.dyndns.org>
 <1303883009.3981.316.camel@sli10-conroe>
 <20110427102034.GE31015@htj.dyndns.org>
 <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org>
 <alpine.DEB.2.00.1104280904240.15775@router.home>
 <20110428142331.GA16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110428142331.GA16552@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Apr 28, 2011 at 04:23:31PM +0200, Tejun Heo wrote:
> Such users then shouldn't use _sum() - maybe rename it to
> _very_slow_sum() if you're concerned about misusage.  percpu_counter()
> is already used in filesystems to count free blocks and there are
> times where atomic_t type accuracy is needed and _sum() achieves that.
> The proposed changes break that.  Why do I need to say this over and
> over again?

And I'm getting more and more frustrated.  THIS IS SLOW PATH.  If it's
showing up on your profile, bump up @batch.  It doesn't make any sense
to micro optimize slow path at the cost of introducing such nastiness.
Unless someone can show me such nastiness doesn't exist, I'm not gonna
take this change.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

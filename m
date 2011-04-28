Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 01B8F6B0023
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:52:38 -0400 (EDT)
Date: Thu, 28 Apr 2011 09:52:35 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <20110428144446.GC16552@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1104280951480.16323@router.home>
References: <20110421190807.GK15988@htj.dyndns.org> <1303439580.3981.241.camel@sli10-conroe> <20110426121011.GD878@htj.dyndns.org> <1303883009.3981.316.camel@sli10-conroe> <20110427102034.GE31015@htj.dyndns.org> <1303961284.3981.318.camel@sli10-conroe>
 <20110428100938.GA10721@htj.dyndns.org> <alpine.DEB.2.00.1104280904240.15775@router.home> <20110428142331.GA16552@htj.dyndns.org> <alpine.DEB.2.00.1104280935460.16323@router.home> <20110428144446.GC16552@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 28 Apr 2011, Tejun Heo wrote:

> Eh?  Are you saying the above can't happen or the above doesn't
> matter?

Its an artificial use case that does not reflect the realities on how
these counters are typically used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

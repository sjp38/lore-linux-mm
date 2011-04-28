Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D78C36B0024
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 12:17:05 -0400 (EDT)
Date: Thu, 28 Apr 2011 11:17:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <1304006345.3360.72.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1104281116270.18213@router.home>
References: <20110427102034.GE31015@htj.dyndns.org>  <1303961284.3981.318.camel@sli10-conroe>  <20110428100938.GA10721@htj.dyndns.org>  <alpine.DEB.2.00.1104280904240.15775@router.home>  <20110428142331.GA16552@htj.dyndns.org>  <alpine.DEB.2.00.1104280935460.16323@router.home>
  <20110428144446.GC16552@htj.dyndns.org>  <alpine.DEB.2.00.1104280951480.16323@router.home>  <20110428145657.GD16552@htj.dyndns.org>  <alpine.DEB.2.00.1104281003000.16323@router.home>  <20110428151203.GE16552@htj.dyndns.org>  <alpine.DEB.2.00.1104281017240.16323@router.home>
  <1304005726.3360.69.camel@edumazet-laptop> <1304006345.3360.72.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Shaohua Li <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 28 Apr 2011, Eric Dumazet wrote:

> > If _sum() notices seqcount was changed too much, restart the loop.

This does not address the issue of cpus adding batch -1 while the
loop is going on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D6B936B002C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:00:04 -0400 (EDT)
Received: by wyf19 with SMTP id 19so3045512wyf.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:00:02 -0700 (PDT)
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1104281152110.18213@router.home>
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
	 <20110428151203.GE16552@htj.dyndns.org>
	 <alpine.DEB.2.00.1104281017240.16323@router.home>
	 <1304005726.3360.69.camel@edumazet-laptop>
	 <1304006345.3360.72.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104281116270.18213@router.home>
	 <1304008533.3360.88.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104281152110.18213@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 18:59:56 +0200
Message-ID: <1304009996.5827.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Shaohua Li <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Le jeudi 28 avril 2011 A  11:52 -0500, Christoph Lameter a A(C)crit :

> I can still add (batch - 1) without causing the seqcount to be
> incremented.

It always had been like that, from the very beginning.

Point was trying to remove the lock, and Tejun said it was going to
increase fuzzyness.

I said : Readers should specify what max fuzzyness they allow.

Most users dont care at all, but we can provide an API.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

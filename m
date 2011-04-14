Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B6335900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:10:37 -0400 (EDT)
Date: Thu, 14 Apr 2011 16:10:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
In-Reply-To: <1302747263.3549.9.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1104141608300.19533@router.home>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>  <alpine.DEB.2.00.1104131148070.20908@router.home>  <20110413185618.GA3987@mtj.dyndns.org>  <alpine.DEB.2.00.1104131521050.25812@router.home> <1302747263.3549.9.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

On Thu, 14 Apr 2011, Eric Dumazet wrote:

> Not sure its a win for my servers, where CONFIG_PREEMPT_NONE=y

Well the fast path would then also be irq safe. Does that bring us
anything?

We could not do the cmpxchg in the !PREEMPT case and instead simply store
the value.

The preempt on/off seems to be a bigger deal for realtime.

> Maybe use here latest cmpxchg16b stuff instead and get rid of spinlock ?

Shaohua already got an atomic in there. You mean get rid of his preempt
disable/enable in the slow path?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

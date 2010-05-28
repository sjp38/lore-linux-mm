Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9717A6B01C1
	for <linux-mm@kvack.org>; Thu, 27 May 2010 22:54:15 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4S2sAP0009423
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 May 2010 11:54:10 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D95545DE50
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:54:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3158545DE4C
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:54:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 09356E08002
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:54:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A574F1DB8016
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:54:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
In-Reply-To: <20100527183319.GA22313@redhat.com>
References: <20100527180431.GP13035@uudg.org> <20100527183319.GA22313@redhat.com>
Message-Id: <20100528090357.7DFB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 May 2010 11:54:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Luis,

> On 05/27, Luis Claudio R. Goncalves wrote:
> >
> > It sounds plausible giving the dying task an even higher priority to be
> > sure it will be scheduled sooner and free the desired memory.
> 
> As usual, I can't really comment the changes in oom logic, just minor
> nits...
> 
> > @@ -413,6 +415,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> >  	 */
> >  	p->rt.time_slice = HZ;
> >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> > +	param.sched_priority = MAX_RT_PRIO-1;
> > +	sched_setscheduler(p, SCHED_FIFO, &param);
> >
> >  	force_sig(SIGKILL, p);
> 
> Probably sched_setscheduler_nocheck() makes more sense.
> 
> Minor, but perhaps it would be a bit better to send SIGKILL first,
> then raise its prio.

I have no objection too. but I don't think Oleg's pointed thing is minor.
Please send updated patch.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

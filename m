Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A2B058D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 06:20:50 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4FB6E3EE081
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 20:20:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 373CC45DE50
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 20:20:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E1EC45DE4D
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 20:20:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 103351DB803B
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 20:20:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D15AA1DB802F
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 20:20:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH rh6] mm: skip zombie in OOM-killer
In-Reply-To: <alpine.DEB.2.00.1103041541040.7795@chino.kir.corp.google.com>
References: <1299274256-2122-1-git-send-email-avagin@openvz.org> <alpine.DEB.2.00.1103041541040.7795@chino.kir.corp.google.com>
Message-Id: <20110306201947.6CCC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  6 Mar 2011 20:20:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> On Sat, 5 Mar 2011, Andrey Vagin wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 7dcca55..2fc554e 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -311,7 +311,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> >  		 * blocked waiting for another task which itself is waiting
> >  		 * for memory. Is there a better alternative?
> >  		 */
> > -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> > +		if (test_tsk_thread_flag(p, TIF_MEMDIE) && p->mm)
> >  			return ERR_PTR(-1UL);
> >  
> >  		/*
> 
> I think it would be better to just do
> 
> 	if (!p->mm)
> 		continue;
> 
> after the check for oom_unkillable_task() because everything that follows 
> this really depends on p->mm being non-NULL to actually do anything 
> useful.

I'm glad you join to review MM patches. It is worth effort for making
solid kernel. But, please look at a current code at first.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

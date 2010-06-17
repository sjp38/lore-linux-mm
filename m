Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 21FB56B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:40 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1pc87005961
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DD39845DE54
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A27645DE4F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BF4D1DB8012
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AB1B61DB8015
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 9/9] oom: give the dying task a higher priority
In-Reply-To: <20100616195447.GH5009@uudg.org>
References: <20100616153120.GH9278@barrios-desktop> <20100616195447.GH5009@uudg.org>
Message-Id: <20100617084943.FB45.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Jun 17, 2010 at 12:31:20AM +0900, Minchan Kim wrote:
> | >         /*
> | >          * We give our sacrificial lamb high priority and access to
> | >          * all the memory it needs. That way it should be able to
> | >          * exit() and clear out its resources quickly...
> | >          */
> | >  	p->rt.time_slice = HZ;
> | >  	set_tsk_thread_flag(p, TIF_MEMDIE);
> ...
> | > +	if (rt_task(p)) {
> | > +		p->rt.time_slice = HZ;
> | > +		return;
> 
> I am not sure the code above will have any real effect for an RT task.
> Kosaki-san, was this change motivated by test results or was it just a code
> cleanup? I ask that out of curiosity.

just cleanup.
ok, I remove this dubious code.

> 
> | I have a question from long time ago. 
> | If we change rt.time_slice _without_ setscheduler, is it effective?
> | I mean scheduler pick up the task faster than other normal task?
> 
> $ git log --pretty=oneline -Stime_slice mm/oom_kill.c
> 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2
> 
> This code ("time_slice = HZ;") is around for quite a while and
> probably comes from a time where having a big time slice was enough to be
> sure you would be the next on the line. I would say sched_setscheduler is
> indeed necessary.

ok


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

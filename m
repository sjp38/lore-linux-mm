Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A8A396B01B5
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 21:51:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5H1peud029654
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 17 Jun 2010 10:51:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D209C45DE57
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E91045DE4F
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 87A4EE08005
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 32DD7E08001
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:51:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 9/9] oom: give the dying task a higher priority
In-Reply-To: <20100616153120.GH9278@barrios-desktop>
References: <20100616203517.72EF.A69D9226@jp.fujitsu.com> <20100616153120.GH9278@barrios-desktop>
Message-Id: <20100617084811.FB42.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 17 Jun 2010 10:51:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

> > +	struct sched_param param = { .sched_priority = 1 };
> > +
> > +	if (mem)
> > +		return;
> > +
> > +	if (rt_task(p)) {
> > +		p->rt.time_slice = HZ;
> > +		return;
> 
> I have a question from long time ago. 
> If we change rt.time_slice _without_ setscheduler, is it effective?
> I mean scheduler pick up the task faster than other normal task?

if p is SCHED_OTHER, no effective. if my understand is correct, that's
only meaningfull if p is SCHED_RR.  that's the reason why I moved this
check into "if (rt_task())".

but honestly I haven't observed this works effectively. so, I agree
this can be removed as Luis mentioned.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

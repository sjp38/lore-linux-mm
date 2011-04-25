Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABE78D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 00:21:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D1DFC3EE0B5
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:21:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA2D845DE96
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:21:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A1A4945DE93
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:21:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93D16E08001
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:21:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61C521DB8037
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:21:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] break out page allocation warning code
In-Reply-To: <20110421103009.731B.A69D9226@jp.fujitsu.com>
References: <1303331695.2796.159.camel@work-vm> <20110421103009.731B.A69D9226@jp.fujitsu.com>
Message-Id: <20110425132333.266E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 25 Apr 2011 13:21:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john stultz <johnstul@us.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

> > > I'd prefer that we remove /proc/pid/comm entirely or at least prevent 
> > > writing to it unless CONFIG_EXPERT.
> > 
> > Eeeh. That's probably going to be a tough sell, as I think there is
> > wider interest in what it provides. Its useful for debugging
> > applications not kernels, so I doubt folks will want to rebuild their
> > kernel to try to analyze a java issue.
> > 
> > So I'm well aware that there is the chance that you catch the race and
> > read an incomplete/invalid comm (it was discussed at length when the
> > change went in), but somewhere I've missed how that's causing actual
> > problems. Other then just being "evil" and having the documented race,
> > could you clarify what the issue is that your hitting?
> 
> The problem is, there is no documented as well. Okay, I recognized you
> introduced new locking rule for task->comm. But there is no documented
> it. Thus, We have no way to review current callsites are correct or not.
> Can you please do it? And, I have a question. Do you mean now task->comm
> reader don't need task_lock() even if it is another thread?
> 
> _if_ every task->comm reader have to realize it has a chance to read
> incomplete/invalid comm, task_lock() doesn't makes any help.

ping?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 63C456B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:28:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA40S9wO004065
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 09:28:09 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E74645DE4E
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:28:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 300AF45DE51
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:28:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 15A201DB8043
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:28:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BCA071DB803B
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:28:08 +0900 (JST)
Date: Wed, 4 Nov 2009 09:25:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm][PATCH 5/6] oom-killer: check last total_vm expansion
Message-Id: <20091104092534.626a2352.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031224270.25890@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
	<20091102162837.405783f3.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031224270.25890@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 12:29:39 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > At considering oom-kill algorithm, we can't avoid to take runtime
> > into account. But this can adds too big bonus to slow-memory-leaker.
> > For adding penalty to slow-memory-leaker, we record jiffies of
> > the last mm->hiwater_vm expansion. That catches processes which leak
> > memory periodically.
> > 
> 
> No, it doesn't, it simply measures the last time the hiwater mark was 
> increased.  That could have increased by a single page in the last tick 
> with no increase in memory consumption over the past year and then its 
> unfairly biased against for quiet_time in the new oom kill heuristic 
> (patch 6).  Using this as part of the badness scoring is ill conceived 
> because it doesn't necessarily indicate a memory leaking task, just one 
> that has recently allocated memory.

Hmm. Maybe I can rewrite this as "periodic expansion have done or not" code.
Okay, this patch itself will be dropped.

If you find better algorithm, let me know.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

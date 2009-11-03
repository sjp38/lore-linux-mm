Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 203C96B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 15:29:52 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id nA3KTiK7003147
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 20:29:44 GMT
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by spaceape14.eur.corp.google.com with ESMTP id nA3KTftE010093
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:29:42 -0800
Received: by pzk34 with SMTP id 34so4396662pzk.11
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 12:29:41 -0800 (PST)
Date: Tue, 3 Nov 2009 12:29:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][-mm][PATCH 5/6] oom-killer: check last total_vm
 expansion
In-Reply-To: <20091102162837.405783f3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031224270.25890@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com> <20091102162837.405783f3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> At considering oom-kill algorithm, we can't avoid to take runtime
> into account. But this can adds too big bonus to slow-memory-leaker.
> For adding penalty to slow-memory-leaker, we record jiffies of
> the last mm->hiwater_vm expansion. That catches processes which leak
> memory periodically.
> 

No, it doesn't, it simply measures the last time the hiwater mark was 
increased.  That could have increased by a single page in the last tick 
with no increase in memory consumption over the past year and then its 
unfairly biased against for quiet_time in the new oom kill heuristic 
(patch 6).  Using this as part of the badness scoring is ill conceived 
because it doesn't necessarily indicate a memory leaking task, just one 
that has recently allocated memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

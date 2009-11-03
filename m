Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A45276B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 15:24:09 -0500 (EST)
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id nA3KO62s011800
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:24:06 -0800
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by zps19.corp.google.com with ESMTP id nA3KLWld012756
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:24:03 -0800
Received: by pwi12 with SMTP id 12so2994218pwi.25
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 12:24:03 -0800 (PST)
Date: Tue, 3 Nov 2009 12:24:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][-mm][PATCH 3/6] oom-killer: count lowmem rss
In-Reply-To: <20091102162617.9d07e05f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031220170.25890@chino.kir.corp.google.com>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com> <20091102162617.9d07e05f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, minchan.kim@gmail.com, vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Count lowmem rss per mm_struct. Lowmem here means...
> 
>    for NUMA, pages in a zone < policy_zone.
>    for HIGHMEM x86, pages in NORMAL zone.
>    for others, all pages are lowmem.
> 
> Now, lower_zone_protection[] works very well for protecting lowmem but
> possiblity of lowmem-oom is not 0 even if under good protection in the kernel.
> (As fact, it's can be configured by sysctl. When we keep it high, there
>  will be tons of not-for-use memory but system will be protected against
>  rare event of lowmem-oom.)

Right, lowmem isn't addressed currently by the oom killer.  Adding this 
constraint will probably make the heuristics much harder to write and 
understand.  It's not always clear that we want to kill a task using 
lowmem just because another task needs some, for instance.  Do you think 
we'll need a way to defer killing any task is no task is heuristically 
found to be hogging lowmem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

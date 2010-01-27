Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BA4F86B0078
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 18:46:22 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o0RNkJUh020156
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 23:46:19 GMT
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by wpaz29.hot.corp.google.com with ESMTP id o0RNk2s8004267
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:46:17 -0800
Received: by pxi36 with SMTP id 36so77468pxi.26
        for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:46:17 -0800 (PST)
Date: Wed, 27 Jan 2010 15:46:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001271541310.4663@chino.kir.corp.google.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com> <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com> <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com> <20100126151202.75bd9347.akpm@linux-foundation.org>
 <20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010, KAMEZAWA Hiroyuki wrote:

> Yes, I think you're right. But "breaking current behaviro of our servers!"
> arguments kills all proposal to this area and this oom-killer or vmscan is
> a feature should be tested by real users.

Nobody has said we should discount lowmem rss when dealing with a GFP_DMA 
allocation, it simply wasn't possible until the lowmem rss counters were 
introduced in -mm.  It would prevent the needless killing of innocent 
tasks which would not allow the page allocation to succeed, so it's a good 
feature to have.  It doesn't need to be configurable at all, we just need 
to find a way to introduce it into the heuristic without mangling oom_adj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

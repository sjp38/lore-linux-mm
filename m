Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 211796B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:51:24 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p0J1pKND001657
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:20 -0800
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by kpbe14.cbf.corp.google.com with ESMTP id p0J1pIou013573
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:18 -0800
Received: by pzk2 with SMTP id 2so58892pzk.32
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:51:18 -0800 (PST)
Date: Tue, 18 Jan 2011 17:51:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <20110118204220.GB18984@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1101181750000.25382@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <20110118101547.GF27152@csn.ul.ie> <alpine.DEB.2.00.1101181211100.18781@chino.kir.corp.google.com> <20110118204220.GB18984@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011, Mel Gorman wrote:

> > It may be the preferred zone even if it isn't allowed by current's cpuset 
> > such as if the allocation is __GFP_WAIT or the task has been oom killed 
> > and has the TIF_MEMDIE bit set, so the preferred zone in the fastpath is 
> > accurate in these cases.  In the slowpath, the former is protected by 
> > checking for ALLOC_CPUSET and the latter is usually only set after the 
> > page allocator has looped at least once and triggered the oom killer to be 
> > killed.
> > 
> 
> Ok, this is reasonable and is a notable distinction from nodemasks. It's
> worth including this in the changelog.
> 

Agreed, and please do s/__GFP_WAIT/!__GFP_WAIT/ for it, too :)

> > I didn't want to add a branch to test for these possibilities in the 
> > fastpath, however, since preferred_zone isn't of critical importance until 
> > it's used in the slowpath (ignoring the statistical usage).
> > 
> 
> With these two paragraphs included in the changelog;
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 

Thanks, and as Andrew noted:

Signed-off-by: David Rientjes <rientjes@google.com>

I'd also suggest this for the -stable tree for 2.6.37.x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

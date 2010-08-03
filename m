Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE4D600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 21:49:02 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o731qnCE012143
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 18:52:49 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by wpaz5.hot.corp.google.com with ESMTP id o731qgqu027631
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 18:52:48 -0700
Received: by pzk3 with SMTP id 3so1747345pzk.36
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 18:52:42 -0700 (PDT)
Date: Mon, 2 Aug 2010 18:52:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org> <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com> <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com> <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
 <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > Hmm, then, oom_score shows the values for all limitations in array ?
> > 
> Anyway, the fact "oom_score can be changed by the context of OOM" may
> confuse admins. "OMG, why low oom_score application is killed! Shit!"
> 
> Please add additional cares for users if we go this way or remove
> user visible oom_score file from /proc.
> 

Sure, a task could be killed with a very low /proc/pid/oom_score, but only 
if its cpuset is oom, for example, and it has the highest score of all 
tasks attached to that oom_score.  So /proc/pid/oom_score needs to be 
considered in the context in which the oom occurs: system-wide, cpuset, 
mempolicy, or memcg.  That's unchanged from the old oom killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

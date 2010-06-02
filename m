Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 445186B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:24:01 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o52LNwda015871
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:23:58 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz13.hot.corp.google.com with ESMTP id o52LNv7j030226
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:23:57 -0700
Received: by pzk32 with SMTP id 32so3288100pzk.21
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:23:57 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:23:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100602222347.F527.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com>
References: <20100601074620.GR9453@laptop> <alpine.DEB.2.00.1006011144340.32024@chino.kir.corp.google.com> <20100602222347.F527.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:

> > I'm glad you asked that because some recent conversation has been 
> > slightly confusing to me about how this affects the desktop; this rewrite 
> > significantly improves the oom killer's response for desktop users.  The 
> > core ideas were developed in the thread from this mailing list back in 
> > February called "Improving OOM killer" at 
> > http://marc.info/?t=126506191200004&r=4&w=2 -- users constantly report 
> > that vital system tasks such as kdeinit are killed whenever a memory 
> > hogging task is forked either intentionally or unintentionally.  I argued 
> > for a while that KDE should be taking proper precautions by adjusting its 
> > own oom_adj score and that of its forked children as it's an inherited 
> > value, but I was eventually convinced that an overall improvement to the 
> > heuristic must be made to kill a task that was known to free a large 
> > amount of memory that is resident in RAM and that we have a consistent way 
> > of defining oom priorities when a task is run uncontained and when it is a 
> > member of a memcg or cpuset (or even mempolicy now), even in the case when 
> > it's contained out from under the task's knowledge.  When faced with 
> > memory pressure from an out of control or memory hogging task on the 
> > desktop, the oom killer now kills it instead of a vital task such as an X 
> > server (and oracle, webserver, etc on server platforms) because of the use 
> > of the task's rss instead of total_vm statistic.
> 
> The above story teach us oom-killer need some improvement. but it haven't
> prove your patches are correct solution. that's why you got to ask testing way.
> 

I would consider what I said above, "when faced with memory pressure from 
an out of control or memory hogging task on the desktop, the oom killer 
now kills it instead of a vital task such as an X server because of the 
use of the task's rss instead of total_vm statistic" as an improvement 
over killing X in those cases which it currently does.  How do you 
disagree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

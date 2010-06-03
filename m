Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BAF0D6B01E9
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 02:49:19 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o536nHO5016227
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:49:17 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by kpbe16.cbf.corp.google.com with ESMTP id o536nF4m003449
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 23:49:15 -0700
Received: by pvf33 with SMTP id 33so373292pvf.3
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 23:49:15 -0700 (PDT)
Date: Wed, 2 Jun 2010 23:48:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100603104314.723D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006022344590.22441@chino.kir.corp.google.com>
References: <20100602222347.F527.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021421540.32666@chino.kir.corp.google.com> <20100603104314.723D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, KOSAKI Motohiro wrote:

> > I would consider what I said above, "when faced with memory pressure from 
> > an out of control or memory hogging task on the desktop, the oom killer 
> > now kills it instead of a vital task such as an X server because of the 
> > use of the task's rss instead of total_vm statistic" as an improvement 
> > over killing X in those cases which it currently does.  How do you 
> > disagree?
> 
> People observed simple s/total_vm/rss/ patch solve X issue.

It doesn't, you need to consider swap as well.

> Then,
> other additional pieces need to explain why that's necessary and
> how to confirm it.
> 

Are you talking about oom_score_adj?  Please read the patch description.

> In other word, I'm sure I'll continue to get OOM bug report in future.
> I'll need to decide revert or not revert each patches. no infomation is
> unwelcome. also, that's the reason why all of rewrite patch is wrong.
> if it will be merged, small bug report eventually is going to make
> all of revert. that doesn't fit our developerment process.
> 

You're speculating that a new problem will be introduced with this change 
that you cannot describe but are concerned that you won't be able to debug 
that unknown issue without simply reverting the entire change?  These 
"nack"ing reasons of yours are getting more and more interesting, I must 
say.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

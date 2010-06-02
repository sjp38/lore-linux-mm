Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2DD6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:21:04 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o52LKxOJ009724
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:21:00 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by kpbe20.cbf.corp.google.com with ESMTP id o52LKwKd020850
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:20:58 -0700
Received: by pxi6 with SMTP id 6so2703165pxi.15
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:20:58 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:20:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100602225252.F536.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006021414210.32666@chino.kir.corp.google.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com> <20100602225252.F536.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:

> I've already explained the reason. 1) all-of-rewrite patches are 
> always unacceptable. that's prevent our code maintainance.

How else would you propose to completely change a heuristic??  By doing it 
in steps where the intermediate changes make an absolute mess of it first 
and then slowly work toward the end result?

This is a complete rewrite of the badness() heuristic, it introduces a new 
userspace interface, oom_score_adj, which it heavily relies upon 
(otherwise it'd be impossible to disable oom killing completely for 
certain tasks, for example), so naturally that needs to be included.

I've followed your suggestion of splitting out the forkbomb detector into 
the next patch, which you don't even have any feedback for either other 
than "nack", so what else do you want from me??

Please follow my suggestion that I've repeatedly made: merge the patch 
locally and check out the new oom_badness() function and see if there's 
anything you're concerned with.  In other words, please actually review 
the implementation and design.

 > 2) no justification
> patches are also unacceptable. you need to write more proper patch descriptaion
> at least.
> 

What needs to be included in the patch description that isn't already?  I 
think it's intention and implementation is clearly spelled out.

> We don't need pointless suggestion. you only need to fix the patch.
> 

It's a review tip to make it easier to read the patch since the complete 
rewrite of oom_badness() is difficult to read in patch form because of the 
breaks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 048496B02AF
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:52:13 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o7Q0qCI9031613
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:52:12 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by wpaz5.hot.corp.google.com with ESMTP id o7Q0qAkO015686
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:52:11 -0700
Received: by pwi4 with SMTP id 4so720269pwi.37
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:52:10 -0700 (PDT)
Date: Wed, 25 Aug 2010 17:52:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008251746200.28401@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com> <20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010, KAMEZAWA Hiroyuki wrote:

> I'm now trying to write a userspace tool to calculate this, for me.
> Then, could you update documentation ? 
> ==
> 3.2 /proc/<pid>/oom_score - Display current oom-killer score
> -------------------------------------------------------------
> 
> This file can be used to check the current score used by the oom-killer is for
> any given <pid>. Use it together with /proc/<pid>/oom_adj to tune which
> process should be killed in an out-of-memory situation.
> ==
> 

You'll want to look at section 3.1 of Documentation/filesystems/proc.txt, 
which describes /proc/pid/oom_score_adj, not 3.2.

> add a some documentation like:
> ==
> (For system monitoring tool developpers, not for usual users.)
> oom_score calculation is implemnentation dependent and can be modified without
> any caution. But current logic is
> 
> oom_score = ((proc's rss + proc's swap) / (available ram + swap)) + oom_score_adj
> 

I'd hesitate to state the formula outside of the implementation and 
instead focus on the semantics of oom_score_adj (as a proportion of 
available memory compared to other tasks), which I tried doing in section 
3.1.  Then, the userspace tool only need be concerned about the units of 
oom_score_adj rather than whether rss, swap, or later extentions such as 
shm are added.

Thanks for working on this, Kame!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

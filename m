Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 120A18D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 17:06:33 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p26M6VO9021298
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 14:06:32 -0800
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by hpaq11.eem.corp.google.com with ESMTP id p26M6STb031185
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 6 Mar 2011 14:06:30 -0800
Received: by pvg3 with SMTP id 3so688288pvg.32
        for <linux-mm@kvack.org>; Sun, 06 Mar 2011 14:06:28 -0800 (PST)
Date: Sun, 6 Mar 2011 14:06:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110306201408.6CC6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103061404210.23737@chino.kir.corp.google.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1103031147560.9993@chino.kir.corp.google.com> <20110306201408.6CC6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Sun, 6 Mar 2011, KOSAKI Motohiro wrote:

> > There is no deadlock being introduced by this patch; if you have an 
> > example of one, then please show it.  The problem is not just overkill but 
> > rather panicking the machine when no other eligible processes exist.  We 
> > have seen this in production quite a few times and we'd like to see this 
> > patch merged to avoid our machines panicking because the oom killer, by 
> > your patch, isn't considering threads that are eligible in the exit path 
> > once their parent has been killed and has exited itself yet memory freeing 
> > isn't possible yet because the threads still pin the ->mm.
> 
> No. While you don't understand current code, I'll not taking yours.
> 

I take this as you declining to show your example of a deadlock introduced 
by this patch as requested.  There is no such deadlock.  The patch is 
reintroducing the behavior of the oom killer that existed for years before 
you broke it and caused many of ours machines to panic as a result.

Thanks for your review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

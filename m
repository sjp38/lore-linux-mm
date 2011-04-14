Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6B57900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 21:12:49 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p3E1Ckib020556
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:12:46 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by hpaq6.eem.corp.google.com with ESMTP id p3E1Ch7C004738
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:12:45 -0700
Received: by pwi5 with SMTP id 5so550882pwi.31
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:12:43 -0700 (PDT)
Date: Wed, 13 Apr 2011 18:12:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] oom: replace PF_OOM_ORIGIN with toggling
 oom_score_adj
In-Reply-To: <BANLkTikx12d+vBpc6esRDYSaFr1dH+9HMA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1104131811470.19388@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com> <20110414090310.07FF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com> <BANLkTikx12d+vBpc6esRDYSaFr1dH+9HMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011, Minchan Kim wrote:

> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 

Thanks!

> Seem to be reasonable and code don't have a problem.
> But couldn't we make the function in general(ex, passed task_struct)
> and use it when we change oom_score_adj(ex, oom_score_adj_write)?
> 

I thought about doing that, but oom_score_adj_write doesn't operate on 
current, so it needs to lock p->sighand differently and also does a test 
to ensure that the new value is only less than the current value for 
CAP_SYS_RESOURCE.  That test is required to take place under the lock as 
well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

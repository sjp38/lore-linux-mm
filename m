Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1074E6B01B2
	for <linux-mm@kvack.org>; Tue, 25 May 2010 20:03:17 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o4Q03Dd9017584
	for <linux-mm@kvack.org>; Tue, 25 May 2010 17:03:14 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by wpaz13.hot.corp.google.com with ESMTP id o4Q03CuG011408
	for <linux-mm@kvack.org>; Tue, 25 May 2010 17:03:12 -0700
Received: by pwj6 with SMTP id 6so435598pwj.40
        for <linux-mm@kvack.org>; Tue, 25 May 2010 17:03:12 -0700 (PDT)
Date: Tue, 25 May 2010 17:02:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1005251700560.15789@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100524100840.1E95.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1005250246170.8045@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, David Rientjes wrote:

> > > oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch
> > 	no objection. but afaik Oleg already pointed out "if (!p->mm)" is bad.
> > 	So, Don't we need push his patch instead?
> > 
> 
> I think it all depends on the order in which this work is merged.
> 

I just noticed that Oleg's patches were dropped as well from -mm so I'll 
merge them into my set and repost them as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

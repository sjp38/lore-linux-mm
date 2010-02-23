Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2153E6B0099
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 03:17:39 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o1N8HXFX017358
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 08:17:33 GMT
Received: from gwb20 (gwb20.prod.google.com [10.200.2.20])
	by spaceape23.eur.corp.google.com with ESMTP id o1N8HWnl007349
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:17:32 -0800
Received: by gwb20 with SMTP id 20so354774gwb.9
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 00:17:31 -0800 (PST)
Date: Tue, 23 Feb 2010 00:17:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/9 v2] oom: select task from tasklist for mempolicy
 ooms
In-Reply-To: <20100223063129.GI3063@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1002230014570.5842@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com> <alpine.DEB.2.00.1002151418030.26927@chino.kir.corp.google.com> <20100223063129.GI3063@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010, Balbir Singh wrote:

> > The oom killer presently kills current whenever there is no more memory
> > free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> > current is a memory-hogging task or that killing it will free any
> > substantial amount of memory, however.
> > 
> > In such situations, it is better to scan the tasklist for nodes that are
> > allowed to allocate on current's set of nodes and kill the task with the
> > highest badness() score.  This ensures that the most memory-hogging task,
> > or the one configured by the user with /proc/pid/oom_adj, is always
> > selected in such scenarios.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Seems reasonable, but I think it will require lots of testing.

I already tested it by checking that tasks with very elevated oom_adj 
values don't get killed when they do not share the same MPOL_BIND nodes as 
a memory-hogging task.

What additional testing did you have in mind?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DB5B46B004D
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 01:31:35 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1N6VUkr002746
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 12:01:30 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1N6VUqQ3055800
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 12:01:30 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1N6VUJN016161
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 17:31:30 +1100
Date: Tue, 23 Feb 2010 12:01:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch -mm 3/9 v2] oom: select task from tasklist for mempolicy
 ooms
Message-ID: <20100223063129.GI3063@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151418030.26927@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002151418030.26927@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-02-15 14:20:06]:

> The oom killer presently kills current whenever there is no more memory
> free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> current is a memory-hogging task or that killing it will free any
> substantial amount of memory, however.
> 
> In such situations, it is better to scan the tasklist for nodes that are
> allowed to allocate on current's set of nodes and kill the task with the
> highest badness() score.  This ensures that the most memory-hogging task,
> or the one configured by the user with /proc/pid/oom_adj, is always
> selected in such scenarios.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Seems reasonable, but I think it will require lots of testing.
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

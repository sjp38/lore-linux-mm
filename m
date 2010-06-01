Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 77AF26B01CC
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:59:31 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o51IxTBE003093
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:59:29 -0700
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by wpaz13.hot.corp.google.com with ESMTP id o51IxR2q023225
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:59:28 -0700
Received: by pxi12 with SMTP id 12so5742805pxi.0
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 11:59:27 -0700 (PDT)
Date: Tue, 1 Jun 2010 11:59:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching
 mm prior to exit
In-Reply-To: <20100601164026.2472.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com> <20100601164026.2472.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, KOSAKI Motohiro wrote:

> > Tasks detach its ->mm prior to exiting so it's possible that in progress
> > oom kills or already exiting tasks may be missed during the oom killer's
> > tasklist scan.  When an eligible task is found with either TIF_MEMDIE or
> > PF_EXITING set, the oom killer is supposed to be a no-op to avoid
> > needlessly killing additional tasks.  This closes the race between a task
> > detaching its ->mm and being removed from the tasklist.
> > 
> > Out of memory conditions as the result of memory controllers will
> > automatically filter tasks that have detached their ->mm (since
> > task_in_mem_cgroup() will return 0).  This is acceptable, however, since
> > memcg constrained ooms aren't the result of a lack of memory resources but
> > rather a limit imposed by userspace that requires a task be killed
> > regardless.
> > 
> > [oleg@redhat.com: fix PF_EXITING check for !p->mm tasks]
> > Acked-by: Nick Piggin <npiggin@suse.de>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> need respin.
> 

No, it applies to mmotm-2010-05-21-16-05 as all of these patches do.  I 
know you've pushed Oleg's patches but they are also included here so no 
respin is necessary unless they are merged first (and I think that should 
only happen if Andrew considers them to be rc material).  I'll base my 
patchsets on the -mm tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

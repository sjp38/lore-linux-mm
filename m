Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8362E6B00A0
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 05:31:17 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n6U9VDCf015574
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 10:31:14 +0100
Received: from pxi37 (pxi37.prod.google.com [10.243.27.37])
	by spaceape8.eur.corp.google.com with ESMTP id n6U9VA3J005208
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 02:31:10 -0700
Received: by pxi37 with SMTP id 37so912466pxi.19
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 02:31:09 -0700 (PDT)
Date: Thu, 30 Jul 2009 02:31:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com> <20090730180029.c4edcc09.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Jul 2009, KAMEZAWA Hiroyuki wrote:

> 1. IIUC, the name is strange.
> 
> At job scheduler, which does this.
> 
> if (vfork() == 0) {
> 	/* do some job */
> 	execve(.....)
> }
> 
> Then, when oom_adj_child can be effective is after execve().
> IIUC, the _child_ means a process created by vfork().
> 

It's certainly a difficult thing to name and I don't claim that "child" is 
completely accurate since, as you said, vfork'd tasks are also children 
of the parent yet they share the same oom_adj value since it's an 
attribute of the shared mm.

If you have suggestions for a better name, I'd happily ack it.

> 2. More simple plan is like this, IIUC.
> 
>   fix oom-killer's select_bad_process() not to be in deadlock.
> 

Alternate ideas?

> rather than this new stupid interface.
> 

Well, thank you.  Regardless of whether you think it's stupid or not, it 
doesn't allow you to livelock the kernel in a very trivial way when the 
oom killer gets invoked prior to execve() and the parent is OOM_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

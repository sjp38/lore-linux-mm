Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9C90D6B01B2
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:33:28 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o53KXOSV022933
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:33:24 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by kpbe14.cbf.corp.google.com with ESMTP id o53KWspE025307
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:33:22 -0700
Received: by pvg16 with SMTP id 16so298514pvg.33
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 13:33:22 -0700 (PDT)
Date: Thu, 3 Jun 2010 13:33:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 09/18] oom: add forkbomb penalty to badness
 heuristic
In-Reply-To: <alpine.DEB.2.00.1006011157050.32024@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006031333070.10856@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015220.29202@chino.kir.corp.google.com> <20100601163705.2460.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011157050.32024@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, David Rientjes wrote:

> On Tue, 1 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > Add a forkbomb penalty for processes that fork an excessively large
> > > number of children to penalize that group of tasks and not others.  A
> > > threshold is configurable from userspace to determine how many first-
> > > generation execve children (those with their own address spaces) a task
> > > may have before it is considered a forkbomb.  This can be tuned by
> > > altering the value in /proc/sys/vm/oom_forkbomb_thres, which defaults to
> > > 1000.
> > > 
> > > When a task has more than 1000 first-generation children with different
> > > address spaces than itself, a penalty of
> > > 
> > > 	(average rss of children) * (# of 1st generation execve children)
> > > 	-----------------------------------------------------------------
> > > 			oom_forkbomb_thres
> > > 
> > > is assessed.  So, for example, using the default oom_forkbomb_thres of
> > > 1000, the penalty is twice the average rss of all its execve children if
> > > there are 2000 such tasks.  A task is considered to count toward the
> > > threshold if its total runtime is less than one second; for 1000 of such
> > > tasks to exist, the parent process must be forking at an extremely high
> > > rate either erroneously or maliciously.
> > > 
> > > Even though a particular task may be designated a forkbomb and selected as
> > > the victim, the oom killer will still kill the 1st generation execve child
> > > with the highest badness() score in its place.  The avoids killing
> > > important servers or system daemons.  When a web server forks a very large
> > > number of threads for client connections, for example, it is much better
> > > to kill one of those threads than to kill the server and make it
> > > unresponsive.
> > > 
> > > [oleg@redhat.com: optimize task_lock when iterating children]
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > nack
> > 
> 
> Why?
> 

Still waiting for an answer to this, KOSAKI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

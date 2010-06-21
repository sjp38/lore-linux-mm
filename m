Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2AE66B01B9
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:47:47 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o5LKlhDn023454
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:47:44 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by kpbe20.cbf.corp.google.com with ESMTP id o5LKlYF3030975
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:47:42 -0700
Received: by pwj7 with SMTP id 7so1357417pwj.32
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:47:42 -0700 (PDT)
Date: Mon, 21 Jun 2010 13:47:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <20100621200549.B53C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006211344240.31743@chino.kir.corp.google.com>
References: <20100608160216.bc52112b.akpm@linux-foundation.org> <alpine.DEB.2.00.1006162213130.19549@chino.kir.corp.google.com> <20100621200549.B53C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:

> > It was in the changelog (recall that the badness() function represents a 
> > proportion of available memory used by a task, so subtracting 30 is the 
> > equivalent of 3% of available memory):
> > 
> > Root tasks are given 3% extra memory just like __vm_enough_memory()
> > provides in LSMs.  In the event of two tasks consuming similar amounts of
> > memory, it is generally better to save root's task.
> 
> LSMs have obvious reason to tend to priotize admin's operation than root
> privilege daemon. otherwise admins can't restore troubles.
> 
> But in this case, why do need priotize admin shell than daemons?
> 

For the same reason.  We want to slightly bias admin shells and their 
processes from being oom killed because they are typically in the business 
of administering the machine and resolving issues that may arise.  It 
would be irresponsible to consider them to have the same killing 
preference as user tasks in the case of a tie.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

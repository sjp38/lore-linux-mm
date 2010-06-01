Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6C0FE6B0224
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:40:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517ejpT016022
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:40:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 063C045DE51
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:40:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D966E45DE4F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:40:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC0BE1DB803E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:40:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A05D1DB803F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:40:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching mm prior to exit
In-Reply-To: <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com>
Message-Id: <20100601164026.2472.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:40:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Tasks detach its ->mm prior to exiting so it's possible that in progress
> oom kills or already exiting tasks may be missed during the oom killer's
> tasklist scan.  When an eligible task is found with either TIF_MEMDIE or
> PF_EXITING set, the oom killer is supposed to be a no-op to avoid
> needlessly killing additional tasks.  This closes the race between a task
> detaching its ->mm and being removed from the tasklist.
> 
> Out of memory conditions as the result of memory controllers will
> automatically filter tasks that have detached their ->mm (since
> task_in_mem_cgroup() will return 0).  This is acceptable, however, since
> memcg constrained ooms aren't the result of a lack of memory resources but
> rather a limit imposed by userspace that requires a task be killed
> regardless.
> 
> [oleg@redhat.com: fix PF_EXITING check for !p->mm tasks]
> Acked-by: Nick Piggin <npiggin@suse.de>
> Signed-off-by: David Rientjes <rientjes@google.com>

need respin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

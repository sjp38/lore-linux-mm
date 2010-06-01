Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B5CB26B01D0
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 14:58:23 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o51IwJs2028945
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:58:19 -0700
Received: from pzk17 (pzk17.prod.google.com [10.243.19.145])
	by hpaq1.eem.corp.google.com with ESMTP id o51IwH7B007642
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 11:58:18 -0700
Received: by pzk17 with SMTP id 17so2823231pzk.5
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 11:58:17 -0700 (PDT)
Date: Tue, 1 Jun 2010 11:58:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 12/18] oom: remove unnecessary code and cleanup
In-Reply-To: <20100601163954.246F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006011157520.32024@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016020.29202@chino.kir.corp.google.com> <20100601163954.246F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, KOSAKI Motohiro wrote:

> > Remove the redundancy in __oom_kill_task() since:
> > 
> >  - init can never be passed to this function: it will never be PF_EXITING
> >    or selectable from select_bad_process(), and
> > 
> >  - it will never be passed a task from oom_kill_task() without an ->mm
> >    and we're unconcerned about detachment from exiting tasks, there's no
> >    reason to protect them against SIGKILL or access to memory reserves.
> > 
> > Also moves the kernel log message to a higher level since the verbosity is
> > not always emitted here; we need not print an error message if an exiting
> > task is given a longer timeslice.
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> need respin.
> 

This is a duplicate of the same patch that you earlier added your 
Reviewed-by line as cited above, what has changed?  This applies fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

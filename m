Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 002766B01AD
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 16:04:12 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o5LK49JK014775
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:04:10 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by kpbe18.cbf.corp.google.com with ESMTP id o5LK3bZP023561
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:04:08 -0700
Received: by pwi9 with SMTP id 9so2364107pwi.37
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 13:04:08 -0700 (PDT)
Date: Mon, 21 Jun 2010 13:04:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/9] oom: oom_kill_process() need to check p is
 unkillable
In-Reply-To: <20100617135224.FBAA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006211301110.8367@chino.kir.corp.google.com>
References: <20100617104647.FB89.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162118520.14101@chino.kir.corp.google.com> <20100617135224.FBAA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jun 2010, KOSAKI Motohiro wrote:

> > > When oom_kill_allocating_task is enabled, an argument task of
> > > oom_kill_process is not selected by select_bad_process(), It's
> > > just out_of_memory() caller task. It mean the task can be
> > > unkillable. check it first.
> > > 
> > 
> > This should be unnecessary if oom_kill_process() appropriately returns 
> > non-zero when it cannot kill a task.  What problem are you addressing with 
> > this fix?
> 
> oom_kill_process() only check its children are unkillable, not its own.

No, oom_kill_process() returns the value of oom_kill_task(victim) which is 
non-zero for !victim->mm in mmotm-2010-06-11-16-40 (and 2.6.34 although 
victim == p in that case).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

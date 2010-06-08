Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4CD6B01D4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:56:40 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o58IubQ7001933
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:56:37 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by wpaz37.hot.corp.google.com with ESMTP id o58IuGt8013391
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:56:36 -0700
Received: by pwj9 with SMTP id 9so431887pwj.32
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:56:36 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:56:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 10/18] oom: enable oom tasklist dump by default
In-Reply-To: <20100608203540.766C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081156110.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525150.32225@chino.kir.corp.google.com> <20100608203540.766C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > --- a/Documentation/sysctl/vm.txt
> > +++ b/Documentation/sysctl/vm.txt
> > @@ -511,7 +511,7 @@ information may not be desired.
> >  If this is set to non-zero, this information is shown whenever the
> >  OOM killer actually kills a memory-hogging task.
> >  
> > -The default value is 0.
> > +The default value is 1 (enabled).
> >  
> >  ==============================================================
> >  
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index ef048c1..833de48 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -32,7 +32,7 @@
> >  
> >  int sysctl_panic_on_oom;
> >  int sysctl_oom_kill_allocating_task;
> > -int sysctl_oom_dump_tasks;
> > +int sysctl_oom_dump_tasks = 1;
> >  static DEFINE_SPINLOCK(zone_scan_lock);
> >  /* #define DEBUG */
> >  
> 
> pulled.
> 

What the heck?  You're not a maintainer, what are you pulling?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

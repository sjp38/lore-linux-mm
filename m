Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 150306B004D
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 02:21:55 -0500 (EST)
Received: by iajr24 with SMTP id r24so10723857iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 23:21:54 -0800 (PST)
Date: Tue, 6 Mar 2012 23:21:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: allow exiting tasks to have access to memory
 reserves
In-Reply-To: <4F570286.8020704@gmail.com>
Message-ID: <alpine.DEB.2.00.1203062316430.4158@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com> <4F570286.8020704@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, 7 Mar 2012, KOSAKI Motohiro wrote:

> As far as I remembered, this idea was sometimes NAKed and you don't bring new
> idea here.

Nope, all patches I've ever proposed for the oom killer have been merged 
in some form or another.

> When exiting a process which have plenty threads, this patch allow to eat all
> of reserve memory
> and bring us new serious failure.
> 

It closes the risk of livelock if an oom killed thread, thread A, cannot 
exit because it's blocked on another thread, thread B, which cannot exit 
because it requires memory in the exit path and doesn't have access to 
memory reserves.  So this patch makes it more likely that an oom killed 
thread will be able to exit without livelocking.

You do remind me that we can remove this logic from select_bad_process(), 
however, as a cleanup which results in more lines being removed than 
added.  I'll reply with a v2.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

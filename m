Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id D41146B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:09:00 -0500 (EST)
Date: Thu, 8 Mar 2012 12:08:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, oom: allow exiting tasks to have access to memory
 reserves
Message-Id: <20120308120859.f7bc8cad.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203062316430.4158@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com>
	<4F570286.8020704@gmail.com>
	<alpine.DEB.2.00.1203062316430.4158@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 6 Mar 2012 23:21:52 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> Nope, all patches I've ever proposed for the oom killer have been merged 
> in some form or another.
> 
> > When exiting a process which have plenty threads, this patch allow to eat all
> > of reserve memory
> > and bring us new serious failure.
> > 
> 
> It closes the risk of livelock if an oom killed thread, thread A, cannot 
> exit because it's blocked on another thread, thread B, which cannot exit 
> because it requires memory in the exit path and doesn't have access to 
> memory reserves.  So this patch makes it more likely that an oom killed 
> thread will be able to exit without livelocking.

But it also "allow to eat all of reserve memory and bring us new
serious failure".  In theory, at least.

And afaict the proposed patch is a theoretical thing as well.  Has
anyone sat down and created tests to demonstrate either problem?  This
patch is either two-steps-forward-and-one-back or it is
one-step-forward-and-two-steps-back.  How are we to determine which of
these it is?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

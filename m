Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A13146B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 22:23:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so11105158pbb.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 19:23:22 -0700 (PDT)
Date: Mon, 18 Jun 2012 19:23:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: do not schedule if current has been killed
In-Reply-To: <4FDFDCA7.8060607@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

On Tue, 19 Jun 2012, Kamezawa Hiroyuki wrote:

> fatal_signal_pending() == false if test_thread_flag(TIF_MEMDIE)==false ?
> 

Yeah, the only thing that sets TIF_MEMDIE is the oom killer and it 
immediately SIGKILLs it afterwards.

Aside: I've been thinking of adding a check to the page allocator for 
!(gfp & __GFP_FS) && !(gfp & __GFP_NORETRY) to set TIF_MEMDIE for current 
if it has a fatal signal since such an allocation isn't eligible for 
calling into the oom killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

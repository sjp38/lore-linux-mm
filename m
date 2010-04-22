Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0626B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:28:47 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o3MASi2n009565
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 03:28:44 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by kpbe12.cbf.corp.google.com with ESMTP id o3MASgTr006460
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 03:28:43 -0700
Received: by pzk34 with SMTP id 34so2486848pzk.33
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 03:28:42 -0700 (PDT)
Date: Thu, 22 Apr 2010 03:28:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100422100944.GX5683@laptop>
Message-ID: <alpine.DEB.2.00.1004220326130.19785@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1004061426420.28700@chino.kir.corp.google.com> <20100407092050.48c8fc3d.kamezawa.hiroyu@jp.fujitsu.com> <20100407205418.FB90.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1004081036520.25592@chino.kir.corp.google.com>
 <20100421121758.af52f6e0.akpm@linux-foundation.org> <20100422072319.GW5683@laptop> <20100422162536.b904203e.kamezawa.hiroyu@jp.fujitsu.com> <20100422100944.GX5683@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010, Nick Piggin wrote:

> Oh actually what happened with the pagefault OOM / panic on oom thing?
> We were talking around in circles about that too.
> 

The oom killer rewrite attempts to kill current first, if possible, and 
then will panic if panic_on_oom is set before falling back to selecting a 
victim.  This is consistent with all other architectures such as powerpc 
that currently do not use pagefault_out_of_memory().  If all architectures 
are eventually going to be converted to using pagefault_out_of_memory() 
with additional work on top of -mm, it would be possible to define 
consistent panic_on_oom semantics for this case.  I welcome such an 
addition since I believe it's a natural extension of panic_on_oom, but I 
believe it should be done consistently so the sysctl doesn't have 
different semantics depending on the underlying arch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

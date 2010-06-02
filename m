Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E721D6B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:09:29 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o52L9RSd030244
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:09:27 -0700
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by wpaz1.hot.corp.google.com with ESMTP id o52L9QFB032206
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:09:26 -0700
Received: by pxi15 with SMTP id 15so1733525pxi.30
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:09:26 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:09:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
In-Reply-To: <20100602223612.F52D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006021405280.32666@chino.kir.corp.google.com>
References: <20100601212023.GA24917@redhat.com> <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com> <20100602223612.F52D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, KOSAKI Motohiro wrote:

> > Again, the question is whether or not the fix is rc material or not, 
> > otherwise there's no difference in the route that it gets upstream: the 
> > patch is duplicated in both series.  If you feel that this minor issue 
> > (which has never been reported in at least the last three years and 
> > doesn't have any side effects other than a couple of millisecond delay 
> > until unuse_mm() when the oom killer will kill something else) should be 
> > addressed in 2.6.35-rc2, then that's a conversation to be had with Andrew.
> 
> Well, we have bugfix-at-first development rule. Why do you refuse our
> development process?
> 

This isn't a bugfix, it simply prevents a recall to the oom killer after 
the kthread has called unuse_mm().  Please show where any side effects of 
oom killing a kthread, which cannot exit, as a result of use_mm() causes a 
problem _anywhere_.

If that's the definition you have for a "bugfix," then I could certainly 
argue that some of my patches like "oom: filter tasks not sharing the same 
cpuset" is a bugfix because it allows needlessly killing tasks that won't 
free memory for current, or "oom: avoid oom killer for lowmem allocations" 
is a bugfix because it allows killing a task that won't free lowmem, etc.

I agree that this is a nice patch to have to avoid that recall later, 
which is why I merged it into my patchset, but let's please be accurate 
about its impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

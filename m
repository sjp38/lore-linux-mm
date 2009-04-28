Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A10546B005A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:38:12 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:38:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428093833.GE21085@elte.hu>
References: <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com> <20090428092918.GC21085@elte.hu> <20090428183237.EBDE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428183237.EBDE.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?utf-8?B?RnLpppjpp7tpYw==?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > 
> > * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> > 
> > > I have no idea how expensive tracepoints are but I suspect they 
> > > don't make too much sense for this particular scenario. After all, 
> > > kmemtrace is mainly interested in _allocation patterns_ whereas 
> > > this patch seems to be more interested in "memory layout" type of 
> > > things.
> > 
> > My point is that the allocation patterns can be derived from dynamic 
> > events. We can build a map of everything if we know all the events 
> > that led up to it. Doing:
> > 
> >   echo 3 > /proc/sys/vm/drop_caches
> > 
> > will clear 99% of the memory allocations, so we can build a new map 
> > from scratch just about anytime. (and if boot allocations are 
> > interesting they can be traced too)
> > 
> > _And_ via this angle we'll also have access to the dynamic events, 
> > in a different 'view' of the same tracepoints - which is obviously 
> > very useful for different purposes.
> 
> I am one of most strongly want guys to MM tracepoint. but No, many 
> cunstomer never permit to use drop_caches.

See my other mail i just sent: it would be a natural extension of 
tracing to also dump all current object state when tracing is turned 
on. That way no drop_caches is needed at all.

But it has to be expressed in one framework that cares about the 
totality of the kernel - not just these splintered bits of 
instrumentation and pieces of statistics.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

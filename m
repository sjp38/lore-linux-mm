Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 411986B005A
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:29:15 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:29:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428092918.GC21085@elte.hu>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu> <20090428074031.GK27382@one.firstfloor.org> <1240909484.1982.16.camel@penberg-laptop> <20090428091508.GA21085@elte.hu> <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> I have no idea how expensive tracepoints are but I suspect they 
> don't make too much sense for this particular scenario. After all, 
> kmemtrace is mainly interested in _allocation patterns_ whereas 
> this patch seems to be more interested in "memory layout" type of 
> things.

My point is that the allocation patterns can be derived from dynamic 
events. We can build a map of everything if we know all the events 
that led up to it. Doing:

  echo 3 > /proc/sys/vm/drop_caches

will clear 99% of the memory allocations, so we can build a new map 
from scratch just about anytime. (and if boot allocations are 
interesting they can be traced too)

_And_ via this angle we'll also have access to the dynamic events, 
in a different 'view' of the same tracepoints - which is obviously 
very useful for different purposes.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99E576B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:04:43 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090428074031.GK27382@one.firstfloor.org>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428074031.GK27382@one.firstfloor.org>
Date: Tue, 28 Apr 2009 12:04:44 +0300
Message-Id: <1240909484.1982.16.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Tue, 2009-04-28 at 09:40 +0200, Andi Kleen wrote:
> > I think i have to NAK this kind of ad-hoc instrumentation of kernel 
> > internals and statistics until we clear up why such instrumentation 
> 
> I think because it has zero fast path overhead and can be used
> any time without enabling anything special.

Yes, zero overhead is important for certain things (like
CONFIG_SLUB_STATS, for example). However, putting slab allocator
specific checks in fs/proc looks pretty fragile to me. It would be nice
to have this under the "kmemtrace umbrella" so that there's just one
place that needs to be fixed up when allocators change.

Also, while you probably don't want to use tracepoints for this kind of
instrumentation, you might want to look into reusing the ftrace
reporting bits.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

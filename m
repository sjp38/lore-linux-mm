Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B62B86B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:06:30 -0400 (EDT)
Date: Tue, 28 Apr 2009 11:10:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428091034.GL27382@one.firstfloor.org>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu> <20090428074031.GK27382@one.firstfloor.org> <1240909484.1982.16.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1240909484.1982.16.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Yes, zero overhead is important for certain things (like
> CONFIG_SLUB_STATS, for example). However, putting slab allocator
> specific checks in fs/proc looks pretty fragile to me. It would be nice

Ok, perhaps that could be put into a inline into slab.h. Would
that address your concerns?

> Also, while you probably don't want to use tracepoints for this kind of
> instrumentation, you might want to look into reusing the ftrace
> reporting bits.

There's already perfectly fine code in tree for this, I don't see why it would
need another infrastructure that doesn't really fit anyways.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

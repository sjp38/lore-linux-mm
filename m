Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 368F76B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 13:43:01 -0400 (EDT)
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20090428093621.GD21085@elte.hu>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428074031.GK27382@one.firstfloor.org>
	 <1240909484.1982.16.camel@penberg-laptop> <20090428091508.GA21085@elte.hu>
	 <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com>
	 <84144f020904280225h490ef682p8973cb1241a1f3ea@mail.gmail.com>
	 <20090428093621.GD21085@elte.hu>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 12:42:08 -0500
Message-Id: <1240940528.938.426.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 11:36 +0200, Ingo Molnar wrote:
> I 'integrate' traces all the time to get summary counts. This series 
> of dynamic events:
> 
>   allocation
>   page count up
>   page count up
>   page count down
>   page count up
>   page count up
>   page count up
>   page count up
> 
> integrates into: "page count is 6".

Perhaps you've failed calculus. The integral is 6 + C.

This is a critical distinction. Tracing is great for looking at changes,
but it completely falls down for static system-wide measurements because
it would require integrating from time=0 to get a meaningful summation.
That's completely useless for taking a measurement on a system that
already has an uptime of months. 

Never mind that summing up page flag changes for every page on the
system since boot time through the trace interface is incredibly
wasteful given that we're keeping a per-page integral in the page tables
anyway.

Tracing is not the answer for everything.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 977A56B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:15:28 -0400 (EDT)
Received: by bwz21 with SMTP id 21so507759bwz.38
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:15:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428091034.GL27382@one.firstfloor.org>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428074031.GK27382@one.firstfloor.org>
	 <1240909484.1982.16.camel@penberg-laptop>
	 <20090428091034.GL27382@one.firstfloor.org>
Date: Tue, 28 Apr 2009 12:15:41 +0300
Message-ID: <84144f020904280215k6e2ae34dk8f1a14a51be2e203@mail.gmail.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andi,

On Tue, Apr 28, 2009 at 12:10 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> Yes, zero overhead is important for certain things (like
>> CONFIG_SLUB_STATS, for example). However, putting slab allocator
>> specific checks in fs/proc looks pretty fragile to me. It would be nice
>
> Ok, perhaps that could be put into a inline into slab.h. Would
> that address your concerns?

Yeah, I'm fine with that. Putting them in the individual
slub_def.h/slob_def.h headers might be even better.

On Tue, Apr 28, 2009 at 12:10 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> Also, while you probably don't want to use tracepoints for this kind of
>> instrumentation, you might want to look into reusing the ftrace
>> reporting bits.
>
> There's already perfectly fine code in tree for this, I don't see why it would
> need another infrastructure that doesn't really fit anyways.

It's just that I suspect that we want page flag printing and
zero-overhead statistics for kmemtrace at some point. But anyway, I'm
not objecting to extending /proc/kpageflags if that's what people want
to do.

                                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

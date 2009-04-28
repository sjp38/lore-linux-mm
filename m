Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 84EEF6B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 06:04:20 -0400 (EDT)
Received: by fxm22 with SMTP id 22so564700fxm.38
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:04:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428093621.GD21085@elte.hu>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428074031.GK27382@one.firstfloor.org>
	 <1240909484.1982.16.camel@penberg-laptop>
	 <20090428091508.GA21085@elte.hu>
	 <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com>
	 <84144f020904280225h490ef682p8973cb1241a1f3ea@mail.gmail.com>
	 <20090428093621.GD21085@elte.hu>
Date: Tue, 28 Apr 2009 12:57:16 +0300
Message-ID: <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Tue, Apr 28, 2009 at 12:36 PM, Ingo Molnar <mingo@elte.hu> wrote:
> I 'integrate' traces all the time to get summary counts. This series
> of dynamic events:
>
> =A0allocation
> =A0page count up
> =A0page count up
> =A0page count down
> =A0page count up
> =A0page count up
> =A0page count up
> =A0page count up
>
> integrates into: "page count is 6".
>
> Note that "integration" can be done wholly in the kernel too,
> without going to the overhead of streaming all dynamic events to
> user-space, just to summarize data into counts, in-kernel. That is
> what the ftrace statistics framework and various ftrace plugins are
> about.
>
> Also, it might make sense to extend the framework with a series of
> 'get current object state' events when tracing is turned on. A
> special case of _that_ would in essence be what the /proc hack does
> now - just expressed in a much more generic, and a much more usable
> form.

I guess the main question here is whether this approach will scale to
something like kmalloc() or the page allocator in production
environments. For any serious workload, the frequency of events is
going to be pretty high.

                                            Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 259706B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 05:24:46 -0400 (EDT)
Received: by bwz21 with SMTP id 21so513453bwz.38
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 02:25:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428074031.GK27382@one.firstfloor.org>
	 <1240909484.1982.16.camel@penberg-laptop>
	 <20090428091508.GA21085@elte.hu>
	 <84144f020904280219p197d5ceag846ae9a80a76884e@mail.gmail.com>
Date: Tue, 28 Apr 2009 12:25:06 +0300
Message-ID: <84144f020904280225h490ef682p8973cb1241a1f3ea@mail.gmail.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 09:40 +0200, Andi Kleen wrote:
>>> > > I think i have to NAK this kind of ad-hoc instrumentation of kernel
>>> > > internals and statistics until we clear up why such instrumentation

* Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>>> > I think because it has zero fast path overhead and can be used
>>> > any time without enabling anything special.
>
> On Tue, Apr 28, 2009 at 12:15 PM, Ingo Molnar <mingo@elte.hu> wrote:
>> ( That's a dubious claim in any case - tracepoints are very cheap.
>> =A0And they could be made even cheaper and such efforts would benefit
>> =A0all the tracepoint users so it's a prime focus of interest.
>> =A0Andi is a SystemTap proponent, right? I saw him oppose pretty much
>> =A0everything built-in kernel tracing related. I consider that a
>> =A0pretty extreme position. )

On Tue, Apr 28, 2009 at 12:19 PM, Pekka Enberg <penberg@cs.helsinki.fi> wro=
te:
> I have no idea how expensive tracepoints are but I suspect they don't
> make too much sense for this particular scenario. After all, kmemtrace
> is mainly interested in _allocation patterns_ whereas this patch seems
> to be more interested in "memory layout" type of things.

That said, I do foresee a need to be able to turn on more detailed
tracing after you've identified problematic areas from kpageflags type
of overview report. And for that, you almost certainly want
kmemtrace/tracepoints style solution with pid/function/whatever regexp
matching ftrace already provides.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC796B004D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 08:42:45 -0400 (EDT)
Date: Tue, 28 Apr 2009 14:42:59 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428124259.GA3731@elte.hu>
References: <20090428093621.GD21085@elte.hu> <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com> <20090428190822.EBED.A69D9226@jp.fujitsu.com> <84144f020904280321u4be9fb10t6f0123b589752b80@mail.gmail.com> <20090428105603.GB25347@elte.hu> <2f11576a0904280409h4dedc04u43a5b68ef492e56d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0904280409h4dedc04u43a5b68ef492e56d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?utf-8?B?RnLpppjpp7tpYw==?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 2009/4/28 Ingo Molnar <mingo@elte.hu>:
> >
> > * Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> >
> >> Hi!
> >>
> >> 2009/4/28 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> >> >> I guess the main question here is whether this approach will scale to
> >> >> something like kmalloc() or the page allocator in production
> >> >> environments. For any serious workload, the frequency of events is
> >> >> going to be pretty high.
> >> >
> >> > Immediate Values patch series makes zero-overhead to tracepoint
> >> > while it's not used.
> >> >
> >> > So, We have to implement to stop collect stastics way. it restore
> >> > zero overhead world.
> >> > We don't lose any performance by trace.
> >>
> >> Sure but I meant the _enabled_ case here. kmalloc() (and the page
> >> allocator to some extent) is very performance sensitive in many
> >> workloads so you probably don't want to use tracepoints if you're
> >> collecting some overall statistics (i.e. tracing all events) like
> >> we do here.
> >
> > That's where 'collect current state' kind of tracepoints would help
> > - they could be used even without enabling any of the other
> > tracepoints. And they'd still be in a coherent whole with the
> > dynamic-events tracepoints.
> >
> > So i'm not arguing against these techniques at all - and we can move
> > on a wide scale from zero-overhead to lots-of-tracing-enabled models
> > - what i'm arguing against is the splintering.
> 
> umm.
> I guess Pekka and you talk about different thing.
> 
> if tracepoint is ON, tracepoint makes one function call. but few 
> hot spot don't have patience to one function call overhead.
> 
> scheduler stat and slab stat are one of good example, I think.
> 
> I really don't want convert slab_stat and sched_stat to ftrace 
> base stastics. currently it don't need extra function call and it 
> only touch per-cpu variable. So, a overhead is extream small.
> 
> Unfortunately, tracepoint still don't reach this extream 
> performance.

I understand that - please see my "[rfc] object collection tracing" 
reply in this thread, for a more detailed description about what i 
meant under 'object state tracing'.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

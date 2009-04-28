Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0E9186B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 06:21:31 -0400 (EDT)
Received: by bwz21 with SMTP id 21so545082bwz.38
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:21:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428190822.EBED.A69D9226@jp.fujitsu.com>
References: <20090428093621.GD21085@elte.hu>
	 <84144f020904280257j57b5b686k91cc4096a8e5ca29@mail.gmail.com>
	 <20090428190822.EBED.A69D9226@jp.fujitsu.com>
Date: Tue, 28 Apr 2009 13:21:50 +0300
Message-ID: <84144f020904280321u4be9fb10t6f0123b589752b80@mail.gmail.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWMgV2Vpc2JlY2tlcg==?= <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

2009/4/28 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
>> I guess the main question here is whether this approach will scale to
>> something like kmalloc() or the page allocator in production
>> environments. For any serious workload, the frequency of events is
>> going to be pretty high.
>
> Immediate Values patch series makes zero-overhead to tracepoint
> while it's not used.
>
> So, We have to implement to stop collect stastics way. it restore
> zero overhead world.
> We don't lose any performance by trace.

Sure but I meant the _enabled_ case here. kmalloc() (and the page
allocator to some extent) is very performance sensitive in many
workloads so you probably don't want to use tracepoints if you're
collecting some overall statistics (i.e. tracing all events) like we
do here.

                                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

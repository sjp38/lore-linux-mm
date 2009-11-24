Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 41EF76B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:49:39 -0500 (EST)
Received: by ewy5 with SMTP id 5so3879164ewy.10
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 10:49:37 -0800 (PST)
Date: Tue, 24 Nov 2009 19:49:35 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
	statistics
Message-ID: <20091124184927.GA4994@nowhere>
References: <4B0B6E44.6090106@cn.fujitsu.com> <20091124090425.GF21991@elte.hu> <4B0BA99D.5020602@cn.fujitsu.com> <20091124100724.GA5570@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091124100724.GA5570@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 11:07:24AM +0100, Ingo Molnar wrote:
> 
> * Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > > 3)
> > > 
> > > it doesnt seem to be working on one of my boxes, which has perf and kmem 
> > > events as well:
> > > 
> > > aldebaran:~/linux/linux/tools/perf> perf kmem record
> > > ^C[ perf record: Woken up 1 times to write data ]
> > > [ perf record: Captured and wrote 0.050 MB perf.data (~2172 samples) ]
> > > 
> > 
> > Seems no kmem event is recorded. No sure what happened here.
> > 
> > Might be that the parameters that perf-kmem passes to perf-record
> > are not properly selected?
> > 
> > Do perf-sched and perf-timechart work on this box?
> 
> yeah:
> 
> aldebaran:~> perf sched record sleep 1
> [ perf record: Woken up 1 times to write data ]
> [ perf record: Captured and wrote 0.017 MB perf.data (~758 samples) ]
> aldebaran:~> perf trace | tail -5
>          distccd-20944 [010]  1792.787376: sched_stat_runtime: comm=distccd pid=20944 runtime=11196 [ns] vruntime=696395420043 [ns]
>             init-0     [009]  1792.914837: sched_stat_wait: comm=x86_64-linux-gc pid=881 delay=10686 [ns]
>             init-0     [009]  1792.915082: sched_stat_sleep: comm=events/9 pid=44 delay=2183651362 [ns]
>               as-889   [013]  1793.008008: sched_stat_runtime: comm=as pid=889 runtime=156807 [ns] vruntime=1553569219042 [ns]
>             init-0     [004]  1793.154400: sched_stat_wait: comm=events/4 pid=39 delay=12155 [ns]
> 
> aldebaran:~> perf kmem record sleep 1
> [ perf record: Woken up 1 times to write data ]
> [ perf record: Captured and wrote 0.078 MB perf.data (~3398 samples) ]
> aldebaran:~> perf trace | tail -5
> aldebaran:~> 
> 
> the perf.data has mmap and exit events - but no kmem events.
> 
> I've attached the config, in case it matters. It runs latest -tip, with 
> your latest series applied as well.
> 
> 	Ingo



I think this is a problem external to kmem events. It's about
trace events/perf in general. It looks like we have some losses.
Steve and Arjan have reported similar things.

I'll investigate this way.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

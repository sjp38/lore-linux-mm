Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6BF8A6B0078
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 06:05:13 -0500 (EST)
Message-ID: <4B0BBDBF.6050806@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 19:04:31 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more statistics
References: <4B0B6E44.6090106@cn.fujitsu.com> <20091124090425.GF21991@elte.hu> <4B0BA99D.5020602@cn.fujitsu.com> <20091124100724.GA5570@elte.hu>
In-Reply-To: <20091124100724.GA5570@elte.hu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Do perf-sched and perf-timechart work on this box?
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

I was using yesterday's -tip tree, and I just updated to the latest -tip,
and I found perf tools are not working:

# ./perf kmem record sleep 3
...
# ./perf trace
            perf-1805  [001]    66.239160: kmem_cache_free: ...
            perf-1806  [000]    66.403561: kmem_cache_alloc: ...
         swapper-0     [000]    66.420099: kmem_cache_free: ...
# ./perf kmem record sleep 3
...
# ./perf trace
# ./perf sched record sleep 3
.../
# ./perf trace
            perf-1825  [000]   103.543014: sched_stat_runtime: ...
# ./perf sched record sleep 3
...
# ./perf trace
#

So I think some new updates on kernel perf_event break.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

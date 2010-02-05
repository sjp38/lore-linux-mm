Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BA90D6B0078
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 16:20:32 -0500 (EST)
Message-ID: <4B6C8B53.2030601@bx.jp.nec.com>
Date: Fri, 05 Feb 2010 16:19:15 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
References: <4B6B7FBF.9090005@bx.jp.nec.com> <20100205072858.GC9320@elte.hu>
In-Reply-To: <20100205072858.GC9320@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jason Baron <jbaron@redhat.com>, Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>, linux-kernel@vger.kernel.org, lwoodman@redhat.com, linux-mm@kvack.org, Tom Zanussi <tzanussi@gmail.com>, riel@redhat.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hello,

(02/05/10 02:28), Ingo Molnar wrote:
> Looks really nice IMO! It also demonstrates nicely the extensibility via 
> Tom's perf trace scripting engine. (which will soon get a Python script 
> engine as well, so Perl and C wont be the only possibility to extend perf 
> with.)
> 
> I've Cc:-ed a few parties who might be interested in this. Wu Fengguang has 
> done MM instrumentation in this area before - there might be some common 
> ground instead of scattered functionality in /proc, debugfs, perf and 
> elsewhere?
> 
> Note that there's also these older experimental commits in tip:tracing/mm 
> that introduce the notion of 'object collections' and adds the ability to 
> trace them:
> 
> 3383e37: tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
> c33b359: tracing, page-allocator: Add trace event for page traffic related to the buddy lists
> 0d524fb: tracing, mm: Add trace events for anti-fragmentation falling back to other migratetypes
> b9a2817: tracing, page-allocator: Add trace events for page allocation and page freeing
> 08b6cb8: perf_counter tools: Provide default bfd_demangle() function in case it's not around
> eb46710: tracing/mm: rename 'trigger' file to 'dump_range'
> 1487a7a: tracing/mm: fix mapcount trace record field
> dcac8cd: tracing/mm: add page frame snapshot trace
> 
> this concept, if refreshed a bit and extended to the page cache, would allow 
> the recording/snapshotting of the MM state of all currently present pages in 
> the page-cache - a possibly nice addition to the dynamic technique you apply 
> in your patches.
> there's similar "object collections" work underway for 'perf lock' btw., by 
> Hitoshi Mitake and Frederic.
>
> So there's lots of common ground and lots of interest.
> 
> Btw., instead of "perf trace record pagecache-usage", you might want to think 
> about introducing a higher level tool as well: 'perf mm' or 'perf pagecache' 
> - just like we have 'perf kmem' for SLAB instrumentation, 'perf sched' for 
> scheduler instrumentation and 'perf lock' for locking instrumentation. [with 
> 'perf timer' having been posted too.]
> 
> 'perf mm' could then still map to Perl scripts, it's just a convenience. It 
> could then harbor other MM related instrumentation bits as well. Just an idea 
> - this is a possibility, if you are trying to achieve higher organization.

Thank you for your information about "perf lock" and "tip:tracing/mm" things.
I think it's very useful to merge 'object collections' about tracing/mm into 
"perf mm". So, I will introduce a higer level tool like "perf mm" for the 
mm related things as next step.
These will help me implement "perf mm".

And tom's perf trace scripting engine is very flexible.
I will try to implement "perf mm" based on his scripting engine and 
harbor other MM related instrumentation like the above if I can.

Thanks,
Keiichi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

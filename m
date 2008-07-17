Received: from toip7.srvr.bell.ca ([209.226.175.124])
          by tomts36-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080717070209.LAIO1669.tomts36-srv.bellnexxia.net@toip7.srvr.bell.ca>
          for <linux-mm@kvack.org>; Thu, 17 Jul 2008 03:02:09 -0400
Date: Thu, 17 Jul 2008 03:02:07 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 09/17] LTTng instrumentation - filemap
Message-ID: <20080717070207.GA30312@Krystal>
References: <20080715222604.331269462@polymtl.ca> <20080715222748.002421557@polymtl.ca> <200807171625.25302.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <200807171625.25302.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

* Nick Piggin (nickpiggin@yahoo.com.au) wrote:
> On Wednesday 16 July 2008 08:26, Mathieu Desnoyers wrote:
> > Instrumentation of waits caused by memory accesses on mmap regions.
> >
> > Those tracepoints are used by LTTng.
> >
> > About the performance impact of tracepoints (which is comparable to
> > markers), even without immediate values optimizations, tests done by Hideo
> > Aoki on ia64 show no regression. His test case was using hackbench on a
> > kernel where scheduler instrumentation (about 5 events in code scheduler
> > code) was added. See the "Tracepoints" patch header for performance result
> > detail.
> 
> BTW. this sort of test is practically useless to measure overhead. If
> a modern CPU is executing out of primed insn/data and branch prediction
> cache, then yes this sort of thing is pretty well free.
> 
> I see *real* workloads that have got continually and incrementally slower
> eg from 2.6.5 to 2.6.20+ as "features" get added. Surprisingly, none of
> them ever showed up individually on a microbenchmark.
> 
> OK, for this case if you can configure it out, I guess that's fine. But
> let's not pretend that adding code and branches and function calls are
> ever free.

I never pretended anything like that. Actually, that's what the
"immediate values" are for : they allow to patch load immediate value
instead of a memory read to decrease d-cache impact. They now allow to
patch a jump instead of the memory read/immediate value read + test +
conditional branch to skip the function call with fairly minimal impact.
I agree with you that eating precious d-cache and jump prediction buffer
entries can eventually slow down the system. But this will be _hard_ to
show on a single macro benchmark, and the microbenchmark showing it will
have to be taken in conditions which will exacerbate the d-cache and BPB
impact.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

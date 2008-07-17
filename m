From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 09/17] LTTng instrumentation - filemap
Date: Thu, 17 Jul 2008 16:25:24 +1000
References: <20080715222604.331269462@polymtl.ca> <20080715222748.002421557@polymtl.ca>
In-Reply-To: <20080715222748.002421557@polymtl.ca>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807171625.25302.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wednesday 16 July 2008 08:26, Mathieu Desnoyers wrote:
> Instrumentation of waits caused by memory accesses on mmap regions.
>
> Those tracepoints are used by LTTng.
>
> About the performance impact of tracepoints (which is comparable to
> markers), even without immediate values optimizations, tests done by Hideo
> Aoki on ia64 show no regression. His test case was using hackbench on a
> kernel where scheduler instrumentation (about 5 events in code scheduler
> code) was added. See the "Tracepoints" patch header for performance result
> detail.

BTW. this sort of test is practically useless to measure overhead. If
a modern CPU is executing out of primed insn/data and branch prediction
cache, then yes this sort of thing is pretty well free.

I see *real* workloads that have got continually and incrementally slower
eg from 2.6.5 to 2.6.20+ as "features" get added. Surprisingly, none of
them ever showed up individually on a microbenchmark.

OK, for this case if you can configure it out, I guess that's fine. But
let's not pretend that adding code and branches and function calls are
ever free.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

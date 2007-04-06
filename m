Date: Fri, 6 Apr 2007 21:40:10 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: preemption and rwsems (was: Re: missing madvise functionality)
Message-ID: <20070406194010.GA21322@elte.hu>
References: <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <19526.1175777338@redhat.com> <20070405191129.GC22092@elte.hu> <20070405133742.88abc4f8.akpm@linux-foundation.org> <20070406090822.GA2425@elte.hu> <20070406123010.802c76b4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070406123010.802c76b4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> > i've attached an updated version of trace-it.c, which will turn this 
> > off itself, using a sysctl. I also made WAKEUP_TIMING default-off.
> 
> ok.  http://userweb.kernel.org/~akpm/to-ingo.txt is the trace of
> 
> 	taskset -c 0 ./jakubs-test-app
> 
> while the system was doing the 150,000 context switches/sec.
> 
> It isn't very interesting.

this shows an idle CPU#7: you should taskset -c 0 trace-it too - it only 
traces the current CPU by default. (there's the 
/proc/sys/kernel/trace_all_cpus flag to trace all cpus, but in this case 
we really want the trace of CPU#0)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D85346B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 09:21:41 -0500 (EST)
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <2f11576a0902190512y1ac60b11s4927533977dc01e7@mail.gmail.com>
References: <1234863220.4744.34.camel@laptop>
	 <499A99BC.2080700@bk.jp.nec.com>
	 <20090217201651.576E.A69D9226@jp.fujitsu.com>
	 <499CE2FE.90503@bk.jp.nec.com>
	 <2f11576a0902190512y1ac60b11s4927533977dc01e7@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 19 Feb 2009 09:21:31 -0500
Message-Id: <1235053291.8424.14.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-19 at 22:12 +0900, KOSAKI Motohiro wrote:
> > Hi Kosaki-san,
> >
> > Thank you for your comment.
> >
> > KOSAKI Motohiro wrote:
> >> Hi
> >>
> >>
> >> In my 1st impression, this patch description is a bit strange.
> >>
> >>> The below patch adds instrumentation for pagecache.
> >>>
> >>> I thought it would be useful to trace pagecache behavior for problem
> >>> analysis (performance bottlenecks, behavior differences between stable
> >>> time and trouble time).
> >>>
> >>> By using those tracepoints, we can describe and visualize pagecache
> >>> transition (file-by-file basis) in kernel and  pagecache
> >>> consumes most of the memory in running system and pagecache hit rate
> >>> and writeback behavior will influence system load and performance.
> >>
> >> Why do you think this tracepoint describe pagecache hit rate?
> >> and, why describe writeback behavior?
> >
> > I mean, we can describe file-by-file basis pagecache usage by using
> > these tracepoints and it is important for analyzing process I/O behavior.
> 
> More confusing.
> Your page cache tracepoint don't have any per-process information.
> 
> 
> > Currently, we can understand the amount of pagecache from "Cached"
> > in /proc/meminfo. So I'd like to understand which files are using pagecache.
> 
> There is one meta question, Why do you think file-by-file pagecache
> infomartion is valueable?
> 

One might take a look at Marcello Tosatti's old 'vmtrace' patch.  It
contains it's own data store/transport via relayfs, but the trace points
could be ported to the current kernel tracing infrastructure.

Here's a starting point:   http://linux-mm.org/VmTrace

Quoting from that page:

>From the previous email to linux-mm:
>"The sequence of pages which a given process or workload accesses
>during its lifetime, a.k.a. "reference trace", is very important
>information. It has been used in the past for comparison of page
>replacement algorithms and other optimizations..."

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 06A6B6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 20:17:36 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1K1Ddds012080
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 20 Feb 2009 10:13:39 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FC7B45DD77
	for <linux-mm@kvack.org>; Fri, 20 Feb 2009 10:13:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 286D245DD74
	for <linux-mm@kvack.org>; Fri, 20 Feb 2009 10:13:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18A2A1DB8043
	for <linux-mm@kvack.org>; Fri, 20 Feb 2009 10:13:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBA7D1DB803F
	for <linux-mm@kvack.org>; Fri, 20 Feb 2009 10:13:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
In-Reply-To: <1235053291.8424.14.camel@lts-notebook>
References: <2f11576a0902190512y1ac60b11s4927533977dc01e7@mail.gmail.com> <1235053291.8424.14.camel@lts-notebook>
Message-Id: <20090220093813.43EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 20 Feb 2009 10:13:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi

> > > Currently, we can understand the amount of pagecache from "Cached"
> > > in /proc/meminfo. So I'd like to understand which files are using pagecache.
> > 
> > There is one meta question, Why do you think file-by-file pagecache
> > infomartion is valueable?
> 
> One might take a look at Marcello Tosatti's old 'vmtrace' patch.  It
> contains it's own data store/transport via relayfs, but the trace points
> could be ported to the current kernel tracing infrastructure.
> 
> Here's a starting point:   http://linux-mm.org/VmTrace
> 
> Quoting from that page:
> 
> >From the previous email to linux-mm:
> >"The sequence of pages which a given process or workload accesses
> >during its lifetime, a.k.a. "reference trace", is very important
> >information. It has been used in the past for comparison of page
> >replacement algorithms and other optimizations..."

Sure.
but strong difference exist.

vmtrace
  - can run standalone
  - reviewer can confirm its output result is useful or not.

Christoph also explained reason more kindly.
I think we need useful consumer. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

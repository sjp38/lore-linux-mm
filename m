Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 650156B01C0
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:27:43 -0400 (EDT)
Date: Tue, 23 Mar 2010 19:27:35 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge
 regression in performance
Message-ID: <20100323182735.GA10897@elte.hu>
References: <bug-15618-10286@https.bugzilla.kernel.org/>
 <20100323102208.512c16cc.akpm@linux-foundation.org>
 <20100323173409.GA24845@elte.hu>
 <20100323111351.756c8752.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100323111351.756c8752.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, ant.starikov@gmail.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 23 Mar 2010 18:34:09 +0100
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > 
> > It shows a very brutal amount of page fault invoked mmap_sem spinning 
> > overhead.
> > 
> 
> Yes.  Note that we fall off a cliff at nine threads on a 16-way.  As soon as 
> a core gets two threads scheduled onto it?

it's AMD Opterons so no SMT.

My (wild) guess would be that 8 cpus can still do cacheline ping-pong 
reasonably efficiently, but it starts breaking down very seriously with 9 or 
more cores bouncing the same single cache-line.

Breakdowns in scalability are usually very non-linear, for hardware and 
software reasons. '8 threads' sounds like a hw limit to me. From the scheduler 
POV there's no big difference between 8 or 9 CPUs used [this is non-HT] - with 
8 or 7 cores still idle.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

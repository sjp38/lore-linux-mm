Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 45AC66B0047
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 12:34:27 -0500 (EST)
Date: Thu, 10 Dec 2009 11:34:03 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
In-Reply-To: <20091210075454.GB25549@elte.hu>
Message-ID: <alpine.DEB.2.00.0912101131200.5481@router.home>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com> <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com> <20091210075454.GB25549@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Dec 2009, Ingo Molnar wrote:

> I.e. why not expose these stats via perf events and counts as well,
> beyond the current (rather minimal) set of MM stats perf supports
> currently?

Certainly one can write perf events that do a simular thing but that is
beyond the scope of the work here. This is the result of a test program.
The point here is to avoid fault regressions while introducing new process
specific counters that are then used by other VM code to make decisions
about a process.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

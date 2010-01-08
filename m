Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDD26B0044
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:39:52 -0500 (EST)
Date: Fri, 8 Jan 2010 11:39:31 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100108192815.GB14141@basil.fritz.box>
Message-ID: <alpine.LFD.2.00.1001081137210.7821@localhost.localdomain>
References: <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain> <20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
 <1262969610.4244.36.camel@laptop> <alpine.LFD.2.00.1001080911340.7821@localhost.localdomain> <alpine.DEB.2.00.1001081138260.23727@router.home> <87my0omo3n.fsf@basil.nowhere.org> <alpine.DEB.2.00.1001081255100.26886@router.home>
 <alpine.LFD.2.00.1001081102120.7821@localhost.localdomain> <20100108192815.GB14141@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Fri, 8 Jan 2010, Andi Kleen wrote:
> 
> With 24 CPU threads cheating is very difficult too.

Stop making value judgements in you word choice, like "cheating".

The fact is, the mmap_sem is per-mm, and works perfectly well. Other 
locking can be vma-specific, but as already mentioned, it's not going to 
_help_, since most of the time even hugely threaded programs will be using 
malloc-like functionality and you have allocations not only cross threads, 
but in general using the same vma. 

Another fact is simply that you shouldn't write your app so that it needs 
to do millions of page faults per second.

So this whole "cheating" argument of yours is total bullshit. It bears no 
relation to reality.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

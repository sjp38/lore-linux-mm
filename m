Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75B13600580
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 15:14:12 -0500 (EST)
Date: Thu, 7 Jan 2010 12:13:28 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001071207040.7821@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001071208550.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105054536.44bf8002@infradead.org>  <alpine.DEB.2.00.1001050916300.1074@router.home>  <20100105192243.1d6b2213@infradead.org>  <alpine.DEB.2.00.1001071007210.901@router.home>
  <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain> <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain> <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
 <alpine.DEB.2.00.1001071308320.2981@router.home> <alpine.LFD.2.00.1001071207040.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 2010, Linus Torvalds wrote:
> 
> Again, it doesn't matter. Old or new - if some other thread looks up the 
> vma, either is fine.

Btw, don't get me wrong. That patch may compile (I checked it), but I am 
not in any way claiming that it is anything else than a total throw-away 
"this is something we could look at doing" suggestion.

For example, I'm not at all wedded to using 'mm->page_table_lock': I in 
fact wanted to use a per-vma lock, but I picked a lock we already had. The 
fact that picking a lock we already had also means that it serializes page 
table updates (sometimes) is actually a downside, not a good thing. 

So the patch was meant to get people thinking about alternatives, rather 
than anything else.

The point being that there are things we can play with on mmap_sem, that 
don't involve getting rid of it - just being a bit more aggressive in how 
we use it.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

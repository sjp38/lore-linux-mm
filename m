Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C970F6B0082
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 00:01:00 -0500 (EST)
Date: Thu, 7 Jan 2010 21:00:34 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100107204940.253ed753@infradead.org>
Message-ID: <alpine.LFD.2.00.1001072058010.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105054536.44bf8002@infradead.org> <alpine.DEB.2.00.1001050916300.1074@router.home> <20100105192243.1d6b2213@infradead.org> <alpine.DEB.2.00.1001071007210.901@router.home>
 <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <alpine.DEB.2.00.1001071025450.901@router.home> <20100107204940.253ed753@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 2010, Arjan van de Ven wrote:
> 
> if an app has to change because our kernel sucks (for no good reason),
> "change the app" really is the lame type of answer.

Well, in all fairness, I doubt other kernels do any better. So changing 
the app is likely to help in general, and thus be at least part of the 
right solution.

But as outlined, we _can_ almost certainly do better on many simple and 
common cases, so changing the kernel - in addition to fixing app memory 
allocation patterns - sounds like a good avenue.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

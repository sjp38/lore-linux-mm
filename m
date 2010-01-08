Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 644706B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 19:42:01 -0500 (EST)
Date: Thu, 7 Jan 2010 16:41:43 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <alpine.LFD.2.00.1001071634500.7821@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.1001071639560.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105054536.44bf8002@infradead.org> <alpine.DEB.2.00.1001050916300.1074@router.home> <20100105192243.1d6b2213@infradead.org> <alpine.DEB.2.00.1001071007210.901@router.home>
 <alpine.LFD.2.00.1001070814080.7821@localhost.localdomain> <1262884960.4049.106.camel@laptop> <alpine.LFD.2.00.1001070934060.7821@localhost.localdomain> <alpine.LFD.2.00.1001070937180.7821@localhost.localdomain> <alpine.LFD.2.00.1001071031440.7821@localhost.localdomain>
 <1262900683.4049.139.camel@laptop> <alpine.LFD.2.00.1001071426590.7821@localhost.localdomain> <20100108092333.1040c799.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001071634500.7821@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 2010, Linus Torvalds wrote:
> 
>  - the patch I sent out just falls back to the old code if it finds 
>    something fishy, so it will do whatever do_brk() does regardless.

Btw, I'd like to state it again - the patch I sent out was not ready to be 
applied. I'm pretty sure it should check things like certain vm_flags 
too(VM_LOCKED etc), and fall back for those cases as well.

So the patch was more meant to illustrate the _concept_ than meant to 
necessarily be taken seriously as-is.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

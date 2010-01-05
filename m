Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 094576007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:12:12 -0500 (EST)
Date: Tue, 5 Jan 2010 08:10:21 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100105154047.GA18217@ZenIV.linux.org.uk>
Message-ID: <alpine.LFD.2.00.1001050802401.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain> <1262681834.2400.31.camel@laptop>
 <alpine.LFD.2.00.1001050727400.3630@localhost.localdomain> <20100105154047.GA18217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Tue, 5 Jan 2010, Al Viro wrote:
> 
> - a bunch of fs operations done from RCU callbacks.  Including severely
> blocking ones.

Yeah, you're right (and Peter also pointed out the might_sleep). That is 
likely to be the really fundamental issue. 

You _can_ handle it (make the RCU callback just schedule the work instead 
of doing it directly), but it does sound really nasty. I suspect we should 
explore just about any other approach over this one. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

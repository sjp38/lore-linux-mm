Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C94626005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 03:18:41 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 05 Jan 2010 09:17:57 +0100
Message-ID: <1262679477.2400.13.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-01-04 at 19:13 -0800, Linus Torvalds wrote:

> I would say that this whole series is _very_ far from being mergeable. 

Never said anything else ;-)

> Peter seems to have been thinking about the details, while missing all the 
> subtle big picture effects that seem to actually change semantics.

Yes, I seem to have missed a rather significant side of the whole
issue..  back to the drawing room for me then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

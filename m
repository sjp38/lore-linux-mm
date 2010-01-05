Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 243B66007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:41:00 -0500 (EST)
Date: Tue, 5 Jan 2010 15:40:47 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-ID: <20100105154047.GA18217@ZenIV.linux.org.uk>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001041904250.3630@localhost.localdomain> <1262681834.2400.31.camel@laptop> <alpine.LFD.2.00.1001050727400.3630@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1001050727400.3630@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 07:34:02AM -0800, Linus Torvalds wrote:

> The only other effects of delaying closing a file I can see are
> 
>  - the ETXTBUSY thing, but we don't need to delay _that_ part, so this may 
>    be a non-issue.
> 
>  - the actual freeing of the data on disk (ie people may expect that the 
>    last close really frees up the space on the filesystem). However, this 
>    is _such_ a subtle semantic thing that maybe nobody cares.

- a bunch of fs operations done from RCU callbacks.  Including severely
blocking ones.  As in "for minutes" in the most severe cases, and with
large numbers of objects involved.  Can get very unpleasant...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

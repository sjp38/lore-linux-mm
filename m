Subject: Re: [patch] mm: fix race in COW logic
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080623121831.GA26555@wotan.suse.de>
References: <20080622153035.GA31114@wotan.suse.de>
	 <Pine.LNX.4.64.0806221742330.31172@blonde.site>
	 <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0806221854050.5466@blonde.site>
	 <20080623014940.GA29413@wotan.suse.de>
	 <Pine.LNX.4.64.0806231015140.3513@blonde.site>
	 <20080623121831.GA26555@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 27 Jun 2008 11:13:12 +0200
Message-Id: <1214557992.2801.24.camel@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-06-23 at 14:18 +0200, Nick Piggin wrote:

> BTW. Yes, the race identified is pretty slim, requiring a lot to happen
> on other CPUs between a small non-preemptible window of instructions,
> it *might* actually happen in practice on larger systems where cachelines
> might be highly contended or take a long time to get from one place to
> another... 

> and the -rt patchset where I assume ptl is preemptible too.

Indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

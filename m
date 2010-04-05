Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8256B01E3
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 15:36:44 -0400 (EDT)
Date: Mon, 5 Apr 2010 21:36:16 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100405193616.GA5125@elte.hu>
References: <patchbomb.1270168887@v2.random>
 <20100405120906.0abe8e58.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100405120906.0abe8e58.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> Problem.  It appears that these patches have only been sent to linux-mm.  
> Linus doesn't read linux-mm and has never seen them.  I do think we should 
> get things squared away with him regarding the overall intent and 
> implementation approach before trying to go further.
> 
> I forwarded "[PATCH 27 of 41] transparent hugepage core" and his summary was 
> "So I don't hate the patch, but it sure as hell doesn't make me happy 
> either.  And if the only advantage is about TLB miss costs, I really don't 
> see the point personally.".  So if there's more benefit to the patches than 
> this, that will need some expounding upon.
> 
> So I'd suggest that you a) address some minor Linus comments which I'll 
> forward separately, b) rework [patch 0/n] to provide a complete description 
> of the benefits and the downsides (if that isn't there already) and c) 
> resend everything, cc'ing Linus and linux-kernel and we'll get it thrashed 
> out.
> 
> Sorry.  Normally I use my own judgement on MM patches, but in this case if I 
> was asked "why did you send all this stuff", I don't believe I personally 
> have strong enough arguments to justify the changes - you're in a better 
> position than I to make that case.  Plus this is a *large* patchset, and it 
> plays in an area where Linus is known to have, err, opinions.

Not sure whether it got mentioned but one area where huge pages are rather 
useful are apps/middleware that does some sort of GC with tons of RAM.

There the 512x reduction in remapping and TLB flush costs (not just TLB miss 
costs) obviously makes for a big difference not just in straight 
performance/latency but also in cache footprint. AFAIK most GC concepts today 
(that cover many gigabytes of memory) are limited by remap and TLB flush 
performance.

So if we accept that shuffling lots of virtual memory is worth doing then the 
next natural step would be to make it transparent.

Just my 2c,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

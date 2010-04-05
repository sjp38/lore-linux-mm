Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE6A86B01E3
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 15:10:27 -0400 (EDT)
Date: Mon, 5 Apr 2010 12:09:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-Id: <20100405120906.0abe8e58.akpm@linux-foundation.org>
In-Reply-To: <patchbomb.1270168887@v2.random>
References: <patchbomb.1270168887@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


Problem.  It appears that these patches have only been sent to
linux-mm.  Linus doesn't read linux-mm and has never seen them.  I do
think we should get things squared away with him regarding the overall
intent and implementation approach before trying to go further.

I forwarded "[PATCH 27 of 41] transparent hugepage core" and his
summary was "So I don't hate the patch, but it sure as hell doesn't
make me happy either.  And if the only advantage is about TLB miss
costs, I really don't see the point personally.".  So if there's more
benefit to the patches than this, that will need some expounding upon.

So I'd suggest that you a) address some minor Linus comments which I'll
forward separately, b) rework [patch 0/n] to provide a complete
description of the benefits and the downsides (if that isn't there
already) and c) resend everything, cc'ing Linus and linux-kernel and
we'll get it thrashed out.


Sorry.  Normally I use my own judgement on MM patches, but in this case
if I was asked "why did you send all this stuff", I don't believe I
personally have strong enough arguments to justify the changes - you're
in a better position than I to make that case.  Plus this is a *large*
patchset, and it plays in an area where Linus is known to have, err,
opinions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD6566B0275
	for <linux-mm@kvack.org>; Wed,  5 May 2010 15:12:15 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1O9k0a-0006hh-Q2
	for linux-mm@kvack.org; Wed, 05 May 2010 19:11:49 +0000
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100505161319.GQ5835@random.random>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
	 <1273065281-13334-2-git-send-email-mel@csn.ul.ie>
	 <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
	 <20100505145620.GP20979@csn.ul.ie>
	 <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
	 <20100505155454.GT20979@csn.ul.ie>  <20100505161319.GQ5835@random.random>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 May 2010 21:11:25 +0200
Message-ID: <1273086685.1642.252.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-05 at 18:13 +0200, Andrea Arcangeli wrote:
> On Wed, May 05, 2010 at 04:54:54PM +0100, Mel Gorman wrote:
> > I'm still thinking of the ordering but one possibility would be to use a mutex
> 
> I can't take mutex in split_huge_page... so I'd need to use an other solution.

So how's that going to work out for my make anon_vma->lock a mutex
patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

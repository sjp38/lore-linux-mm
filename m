Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 611756B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 02:25:40 -0400 (EDT)
Date: Mon, 13 Jul 2009 08:46:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090713064641.GL14666@wotan.suse.de>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090708173206.GN356@random.random> <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 12:18:07PM +0100, Hugh Dickins wrote:
> On Wed, 8 Jul 2009, Andrea Arcangeli wrote:
> > On Tue, Jul 07, 2009 at 06:06:29PM +0900, KAMEZAWA Hiroyuki wrote:
> > harmful as there's a double page fault generated instead of a single
> > one, kksmd has a cost but zeropage isn't free either in term of page
> > faults too)
> 
> Much as I like KSM, I have to agree with Avi, that if people are
> wanting the ZERO_PAGE back in compute-intensive loads, then relying

I can't imagine ZERO_PAGE would be too widely used in compute-intensive
loads. At least, not serious stuff. Nobody wants to spend 4K of cache
and one TLB entry for one or two non-zero floating point numbers in a
big sparse matrix. Not to mention the cache and memory overhead of just
scanning through lots of zeros.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

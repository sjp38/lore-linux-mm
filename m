Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA04870
	for <linux-mm@kvack.org>; Wed, 10 Dec 1997 10:27:47 -0500
Date: Wed, 10 Dec 1997 16:21:40 +0100
Message-Id: <199712101521.QAA25114@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <87g1o1nxxd.fsf@atlas.infra.CARNet.hr> (message from Zlatko
	Calusic on 10 Dec 1997 14:13:34 +0100)
Subject: Re: Ideas for memory management hackers.
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


[patch deleted ... found at http://www.fys.ruu.nl/~riel/ :-)]

> 
> It was originally developed for 2.1.61, but it works perfectly on
> 2.1.71 (I just checked). It was posted on linux-kernel list during
> recent problems (massive unsubscribe), so many people missed it.
> 
> Now some comments on the patch:
> 
> I had nasty lockups with all 2.1 kernels. I traced problem down to the
> network stuff which was trying to allocate pages of order 2 what was
> constantly failing. Problem was (and still is!) that Linux doesn't
> swap pages out to get more free memory if it already has
> free_pages_high or more free pages. Of course, it is correct
> behaviour, but... sometimes memory is completely fragmented, and all
> free chunks are of one or two pages, so there's no way you could get
> 16KB of contiguous memory (even if you have 512KB free!). Networking
> can't proceed without that and if you're logged remotely you're in
> fact completely disconnected.

In other words a better memory defragmentation is needed for 2.2, isn't it?
A simple approach could be an addition address check during the scans
in shrink_mmap (mm/filemap.c) instead of a freeing the first unused
(random) page. This could be used in the first few priorities to free pages
mostly useful for defragmentation.

An other approach is Ben's anonymous ageing of physical task pages
found in http://www.kvack.org/~blah/patches/v2_1_47_ben1.gz ... 
this approach gives a link of the pte of a page needed for ageing
the page.


           Werner

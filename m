Message-ID: <3D405428.7EC4B715@zip.com.au>
Date: Thu, 25 Jul 2002 12:40:24 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] start_aggressive_readahead
References: <20020725181059.A25857@lst.de> <Pine.LNX.4.44L.0207251343180.8815-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Thu, 25 Jul 2002, Christoph Hellwig wrote:
> 
> > This function (start_aggressive_readahead()) checks whether all zones
> > of the given gfp mask have lots of free pages.
> 
> Seems a bit silly since ideally we wouldn't reclaim cache memory
> until we're low on physical memory.
> 

Yes, I would question its worth also.


What it boils down to is:  which pages are we, in the immediate future,
more likely to use?  Pages which are at the tail of the inactive list,
or pages which are in the file's readahead window?

I'd say the latter, so readahead should just go and do reclaim.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

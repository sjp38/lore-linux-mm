Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA31347
	for <linux-mm@kvack.org>; Sun, 24 May 1998 10:32:13 -0400
Subject: Re: Swapping in 2.1.103?
References: <Pine.LNX.3.91.980522051257.32316B-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 24 May 1998 09:05:31 -0500
In-Reply-To: Rik van Riel's message of Fri, 22 May 1998 05:21:32 +0200 (MET DST)
Message-ID: <m1g1hz4vdg.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> [CC:d to linux-mm because of the TODO list and because Jim
RR>  is generally suggesting to team up with us :) ]

Well here are my 2 cents for the TODO list.

RR> We have several things in the TODO list currently:
RR> - reverse pte lookup  -- being done by sct and blah
RR> - true swapping -- I have the designs next to me, NYI
RR> - out-of-memory process killing -- you can download the bulk
RR> 				of the code from my homepage
RR> - swapin clustering -- I have some random thoughts, but NYI
RR> - a zone allocator, instead of the current buddy allocator
RR> 		-- I have the design, but NYI
RR> - some minor kswapd fixes -- we know what to fix, just not
RR> 			how, and it's minor anyway...
RR> - prepaging -- I have some ideas on how to do this, no
RR> 			solid design and NYI
      I think reverse pte lookup and a pgflush daemon (see below)
      could handle most of this.  We would still need kswapd for page
      aging,  and the issue of when to start prepaging.... 

    - foreign swap allocation -- cleaning up the interface to swap
        pages so my shmfs filesystem, SYSV shared memory, and someday
        others, can handle swapoff and so rw_page_cache isn't so
        possesive.  In progress.
    - dirty page cache pages 
	-- Adding code so we can write things directly out of the page
           cache.  This should help compressed filesystems, and
           network filesystems for whom the block cache doesn't work.

           I have written shmfs a totally nonsynchronous filesystem
           that resides in swap, and uses my test code.  Currently I
           have some resource allocations issues to deal with for
           swap, and a pgflush kernel daemon to write (which should
           also be able to handle prepaging...), to write out dirty
           data in a timely manner.

Eric

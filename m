Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA19921
	for <linux-mm@kvack.org>; Mon, 30 Nov 1998 17:29:12 -0500
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
References: <Pine.LNX.3.96.981130202517.274A-100000@mirkwood.dummy.home>
Reply-To: Zlatko.Calusic@CARNet.hr
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 30 Nov 1998 23:27:07 +0100
In-Reply-To: Rik van Riel's message of "Mon, 30 Nov 1998 20:29:35 +0100 (CET)"
Message-ID: <87sof0ke9w.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Benjamin Redelings I <bredelin@ucsd.edu>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

> I am now trying:
> 	if (buffer_over_borrow() || pgcache_over_borrow() ||
> 			atomic_read(&nr_async_pages)
> 		shrink_mmap(i, gfp_mask);
> 
> Note that this doesn't stop kswapd from swapping out so
> swapout performance shouldn't suffer. It does however
> free up memory so kswapd should _terminate_ and keep the
> amount of I/O done to a sane level.

This still slows down swapping somewhat (20-30%) in my tests.

> 
> Note that I'm running with my experimentas swapin readahead
> patch enabled so the system should be stressed even more
> than normally :)
> 

I tried your swapin_readahead patch but it didn't work right:

swap_duplicate at c012054b: entry 00011904, unused page 
swap_duplicate at c012054b: entry 002c8c00, unused page 
swap_duplicate at c012054b: entry 00356700, unused page 
swap_duplicate at c012054b: entry 00370f00, unused page 
swap_duplicate at c012054b: entry 0038d000, unused page 
swap_duplicate at c012054b: entry 0039d100, unused page 
swap_duplicate at c012054b: entry 0000b500, unused page 

c012054b is read_swap_cache_async()

Memory gets eaten when I bang MM, and after sometime system blocks. I
also had one FS corruption, thanks to that. Didn't investigate
further.

Do you have a newer version of the patch?

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	       Multitasking attempted. System confused.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

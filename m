Received: from Cantor.suse.de (Cantor.suse.de [194.112.123.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA16170
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 17:20:59 -0500
Message-ID: <19981123231903.17506@boole.suse.de>
Date: Mon, 23 Nov 1998 23:19:03 +0100
From: "Dr. Werner Fink" <werner@suse.de>
Subject: Re: Linux-2.1.129..
References: <m1r9uudxth.fsf@flinx.ccr.net> <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>; from Linus Torvalds on Mon, Nov 23, 1998 at 12:02:41PM -0800
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > ST> That would be true if we didn't do the free_page_and_swap_cache trick.
> > ST> However, doing that would require two passes: once by the swapper, and
> > ST> once by shrink_mmap(): before actually freeing a page. 
> 
> This is something I considered doing. It has various advantages, and it's
> almost done already in a sense: the swap cache thing is what would act as
> the buffer between the two passes. 
> 
> Then the page table scanning would never really page anything out: it
> would just move things into the swap cache. That makes the table scanner
> simpler, actually. The real page-out would be when the swap-cache is
> flushed to disk and then freed.

Furthermore this would give a good getting in for a effective ageing
scheme for often needed pages. Pages frequently going in and out of the
swap cache are the best candidates to get an higher page age.

> 
> I'd like to see this, although I think it's way too late for 2.2
> 
> 		Linus

Better doing it know than within 2.2 ;^)

           Werner

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA15353
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 15:04:26 -0500
Date: Mon, 23 Nov 1998 12:02:41 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Linux-2.1.129..
In-Reply-To: <m1r9uudxth.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On 23 Nov 1998, Eric W. Biederman wrote:
> 
> ST> That would be true if we didn't do the free_page_and_swap_cache trick.
> ST> However, doing that would require two passes: once by the swapper, and
> ST> once by shrink_mmap(): before actually freeing a page. 

This is something I considered doing. It has various advantages, and it's
almost done already in a sense: the swap cache thing is what would act as
the buffer between the two passes. 

Then the page table scanning would never really page anything out: it
would just move things into the swap cache. That makes the table scanner
simpler, actually. The real page-out would be when the swap-cache is
flushed to disk and then freed.

I'd like to see this, although I think it's way too late for 2.2

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Received: from mail.ccr.net (ccr@alogconduit1ar.ccr.net [208.130.159.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA17496
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 22:23:38 -0500
Subject: Re: Linux-2.1.129..
References: <Pine.LNX.3.95.981123120028.5712B-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 Nov 1998 21:37:33 -0600
In-Reply-To: Linus Torvalds's message of "Mon, 23 Nov 1998 12:02:41 -0800 (PST)"
Message-ID: <m1emqtep6q.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:

LT> On 23 Nov 1998, Eric W. Biederman wrote:
>> 
ST> That would be true if we didn't do the free_page_and_swap_cache trick.
ST> However, doing that would require two passes: once by the swapper, and
ST> once by shrink_mmap(): before actually freeing a page. 

LT> This is something I considered doing. It has various advantages, and it's
LT> almost done already in a sense: the swap cache thing is what would act as
LT> the buffer between the two passes. 

LT> Then the page table scanning would never really page anything out: it
LT> would just move things into the swap cache. That makes the table scanner
LT> simpler, actually. The real page-out would be when the swap-cache is
LT> flushed to disk and then freed.

LT> I'd like to see this, although I think it's way too late for 2.2

Agreed.

But something quite similiar is still possible.

Not removing pages from the swap cache while they are in flight.
Letting shrink-mmap remove all of the clean pages from memory.

This can be implemented by simply removing code.

And it provides a weak kind of aging, so heavily used pages will not
be removed from memory, just minor faults will occur.

For 2.2 we can either experiment with minor variations on no swap
aging, taking a little longer.  Or we can put it swap aging back in,
and run with a system people have confidence in already.



And now for my 2 cents.

For a policy more akin to what we have with the buffer cache I have
been working on generic dirty page handling for the whole page cache,
that I intend to send to submit for early 2.3.   

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

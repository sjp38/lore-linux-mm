From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
In-Reply-To: <Pine.LNX.4.10.10001040417340.654-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.10.10001041643050.654-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Date: Tue, 4 Jan 2000 16:47:53 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jan 2000, Rik van Riel wrote:

> d+r+h > limit
> d     > limit/2
> r     > limit/4
> h     > limit/8

Ehmmm, wait. I messed up on this one.
We probably want to have a bit more freedom
so the page freeing algorithm doesn't do too
much scanning for nothing.

d+r+h 	> limit
d	> limit/4
r	> limit/4
h	don't care, even on a 1.5GB machine h will
	be 1/3 of total memory, so we'll usually
	have a few free pages in here

> DMA pages should always be present, regular pages for
> storing pagetables and stuff need to be there too, higmem
> pages we don't really care about.
> 
> Btw, I think we probably want to increase freepages.min
> to 512 or even more on machines that have >1GB of memory.
> The current limit of 256 was really intended for machines
> with a single zone of memory...
> 
> (but on <1GB machines I don't know if it makes sense to
> raise the limit much more ... maybe we should raise the
> limit automagically if the page alloc/io rate is too
> high?)

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/

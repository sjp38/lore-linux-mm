Date: Mon, 28 Jun 1999 21:00:10 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <14199.62834.984162.69753@dukat.scot.redhat.com>
Message-ID: <Pine.BSO.4.10.9906282055210.10964-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Stephen C. Tweedie wrote:
> On Mon, 28 Jun 1999 17:32:05 -0400 (EDT), Chuck Lever <cel@monkey.org>
> said:
> 
> > well, except that kswapd itself doesn't free any memory.  
> 
> It has to.  That was why kswapd was initially written, to ensure that
> interrupt memory requests (eg. busy router boxes) don't starve of
> memory.  All of the benefits of kswapd came later.  In normal kernels
> the try_to_swap_out doesn't free memory, true enough, but kswapd calls
> shrink_mmap() too to make sure it does make real progress in freeing
> memory.

again, foot in mouth.  i meant kswapd doesn't free any memory *by simply
swapping*.  that's what i get for typing when i'm hungry.

> > if you need evidence that shrink_mmap() will keep a system running without
> > swapping, just run 2.3.8 :) :)
> 
> 2.3.8 shows up slower on several benchmarks because of its reluctance to
> swap.

right, agreed.  but it doesn't stall, it just slows down.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

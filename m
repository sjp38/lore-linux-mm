Date: Thu, 9 Dec 1999 21:39:45 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <199912092031.MAA40950@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.05.9912092136180.17600-100000@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 1999, Kanoj Sarcar wrote:
> > Ingo Molnar wrote:
> > > hm, does anyone have any conceptual problem with a new
> > > allocate_largemem(pages) interface in page_alloc.c? It's not terribly hard
> > > to scan all bitmaps for available RAM and mark the large memory area
> > > allocated and remove all pages from the freelists. Such areas can only be
> > > freed via free_largemem(pages). Both calls will be slow, so should be only
> > > used at driver initialization time and such.
> > 
> > Would this interface swap out user pages if necessary?  That sort of
> > interface would be great, and kill a number of hacks floating around out
> > there.
> 
> Swapping out user pages is not a sure shot thing unless Linux implements
> reverse maps, so that we can track which page is being used by which pte. 
> 
> Without rmaps, any possible solution will be quite costly, if not an 
> outright hack, IMO. 

Not only that, we would also need to make
sure that no kernel data pages are in the way.

This means we'll need both reverse maps and
a "real" zoned allocator. Not a 2.4 thing,
I'm afraid :(

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912092054.MAA57205@google.engr.sgi.com>
Subject: Re: Getting big areas of memory, in 2.3.x?
Date: Thu, 9 Dec 1999 12:54:11 -0800 (PST)
In-Reply-To: <Pine.LNX.4.05.9912092136180.17600-100000@humbolt.nl.linux.org> from "Rik van Riel" at Dec 9, 99 09:39:45 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: jgarzik@mandrakesoft.com, mingo@chiara.csoma.elte.hu, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> On Thu, 9 Dec 1999, Kanoj Sarcar wrote:
> > > Ingo Molnar wrote:
> > > > hm, does anyone have any conceptual problem with a new
> > > > allocate_largemem(pages) interface in page_alloc.c? It's not terribly hard
> > > > to scan all bitmaps for available RAM and mark the large memory area
> > > > allocated and remove all pages from the freelists. Such areas can only be
> > > > freed via free_largemem(pages). Both calls will be slow, so should be only
> > > > used at driver initialization time and such.
> > > 
> > > Would this interface swap out user pages if necessary?  That sort of
> > > interface would be great, and kill a number of hacks floating around out
> > > there.
> > 
> > Swapping out user pages is not a sure shot thing unless Linux implements
> > reverse maps, so that we can track which page is being used by which pte. 
> > 
> > Without rmaps, any possible solution will be quite costly, if not an 
> > outright hack, IMO. 
> 
> Not only that, we would also need to make
> sure that no kernel data pages are in the way.
> 
> This means we'll need both reverse maps and
> a "real" zoned allocator. Not a 2.4 thing,
> I'm afraid :(
>

Well, at least in 2.3, kernel data (and page caches) are below 1G,
which means there's a lot of memory possible out there with
references only from user memory. Shm page references are 
revokable too. Of course, in 2.5, things will probably change. 

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Date: Fri, 10 Dec 1999 00:15:13 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <38501014.E5066331@mandrakesoft.com>
Message-ID: <Pine.LNX.4.10.9912100013260.10946-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 1999, Jeff Garzik wrote:

> > hm, does anyone have any conceptual problem with a new
> > allocate_largemem(pages) interface in page_alloc.c? It's not terribly hard
> > to scan all bitmaps for available RAM and mark the large memory area
> > allocated and remove all pages from the freelists. Such areas can only be
> > freed via free_largemem(pages). Both calls will be slow, so should be only
> > used at driver initialization time and such.
> 
> Would this interface swap out user pages if necessary?  That sort of
> interface would be great, and kill a number of hacks floating around out
> there.

not at the moment - but it's not really necessery because this is ment for
driver initialization time, which usually happens at boot time.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

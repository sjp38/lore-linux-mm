From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14417.1440.795510.93176@dukat.scot.redhat.com>
Date: Fri, 10 Dec 1999 13:52:32 +0000 (GMT)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912091319030.1223-100000@chiara.csoma.elte.hu>
References: <384F17BA.174B4C6D@mandrakesoft.com>
	<Pine.LNX.4.10.9912091319030.1223-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 9 Dec 1999 13:25:00 +0100 (CET), Ingo Molnar
<mingo@chiara.csoma.elte.hu> said:

> hm, does anyone have any conceptual problem with a new
> allocate_largemem(pages) interface in page_alloc.c? It's not
> terribly hard to scan all bitmaps for available RAM and mark the
> large memory area allocated and remove all pages from the
> freelists. 

Even better: the zoned allocator makes it pretty easy to reserve (say)
the top 25% of memory for use only by freeable (ie. page cache and
anonymous) pages: just make a separate zone for that.  If there is
memory that you know you can reshuffle, then a slow, swapout-style
exhaustive VM search will eventually let you allocate any page you
want from that zone (barring only mlock()ed pages).

That's maybe more work than we want for a problem which may disappear
eventually of its own accord: a lot of AGP chipsets these days have a
GART which is visible from the PCI side, and that lets you map
discontiguous physical pages into a virtual region which looks
contiguous to the PCI hardware.  There's similar hardware on the Sparc
and Alpha PCI boxes (is it universal on PCI buses on those platforms?)

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

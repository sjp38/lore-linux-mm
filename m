Message-ID: <38501014.E5066331@mandrakesoft.com>
Date: Thu, 09 Dec 1999 15:24:52 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Getting big areas of memory, in 2.3.x?
References: <Pine.LNX.4.10.9912091319030.1223-100000@chiara.csoma.elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> hm, does anyone have any conceptual problem with a new
> allocate_largemem(pages) interface in page_alloc.c? It's not terribly hard
> to scan all bitmaps for available RAM and mark the large memory area
> allocated and remove all pages from the freelists. Such areas can only be
> freed via free_largemem(pages). Both calls will be slow, so should be only
> used at driver initialization time and such.

Would this interface swap out user pages if necessary?  That sort of
interface would be great, and kill a number of hacks floating around out
there.

-- 
Jeff Garzik              | Just once, I wish we would encounter
Building 1024            | an alien menace that wasn't immune to
MandrakeSoft, Inc.       | bullets.   -- The Brigadier, "Dr. Who"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

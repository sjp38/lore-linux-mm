Message-ID: <380ECA51.E1210AFD@mandrakesoft.com>
Date: Thu, 21 Oct 1999 04:09:53 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Paging out sleepy processes?
References: <380D7C24.AA10E463@mandrakesoft.com> <380EA6C1.DA32BC3A@263.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: wung_y@263.net
Cc: mail list linux-mm mail list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wang Yong wrote:
> Jeff Garzik wrote:
> > How possible/reasonable would it be to add a feature which will swap out
> > processes that have been asleep for a long time?

> why do u want to force it out

Processes will not get swapped out until memory pressure occurs.  Thus,
idle processes waste physical memory until this situation occurs. 
Physical memory is always a valuable commodity, and should IMHO be
reclaimed whenever possible.

It makes even more sense to page out idle _pages_ instead of processes,
but I don't know if it is even possible to determine how long a page has
been idle, in terms of clock time.

	Jeff
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

Date: Thu, 13 Jan 2000 22:12:05 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.21.0001132059590.981-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001132159360.13454-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Andrea Arcangeli wrote:

> --- 2.3.40pre1/mm/vmscan.c	Sun Jan  9 20:45:31 2000
> +++ /tmp/vmscan.c	Thu Jan 13 21:09:33 2000
> @@ -503,7 +503,7 @@
>  		do {
>  			/* kswapd is critical to provide GFP_ATOMIC
>  			   allocations (not GFP_HIGHMEM ones). */
> -			if (nr_free_buffer_pages() >= freepages.high)
> +			if (nr_free_pages() - nr_free_highpages() >= freepages.high)
>  				break;
>  			if (!do_try_to_free_pages(GFP_KSWAPD, 0))
>  				break;

Indeed. Linus, please apply this patch...

Btw, shouldn't we make do_try_to_free_pages() a bit smarter
so that it doesn't free high memory pages when there are
enough free pages in that part of memory.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/

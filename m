Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA16920
	for <linux-mm@kvack.org>; Thu, 10 Dec 1998 08:51:56 -0500
Date: Thu, 10 Dec 1998 13:50:46 GMT
Message-Id: <199812101350.NAA03113@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <Pine.LNX.3.96.981209183310.3727A-100000@laser.bogus>
References: <199812072204.WAA01733@dax.scot.redhat.com>
	<Pine.LNX.3.96.981209183310.3727A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 9 Dec 1998 18:43:25 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> I think that my state = 0 in do_try_to_free_page() helped a lot to handle
> the better kernel performance.

Have you done any benchmarking on it?  The VM is now looking pretty
good, and I'd be very reluctant to keep tweaking it now without solid
evidence as to how that will affect performance: we need to draw a line
somewhere for 2.2.  I think we're now beyond the point where it makes
sense to say "here, try THIS patch to see what happens" without at least
making some attempt to test it first.

> And why not to use GFP_USER in the userspace swaping code?

Good point.


> Index: linux/mm/swap_state.c
> diff -u linux/mm/swap_state.c:1.1.3.2 linux/mm/swap_state.c:1.1.1.1.2.4
> --- linux/mm/swap_state.c:1.1.3.2	Wed Dec  9 16:11:46 1998
> +++ linux/mm/swap_state.c	Wed Dec  9 18:39:03 1998
> @@ -308,7 +336,7 @@
>  	if (found_page)
>  		goto out;
> 
> -	new_page_addr = __get_free_page(GFP_KERNEL);
> +	new_page_addr = __get_free_page(GFP_USER);
>  	if (!new_page_addr)
>  		goto out;	/* Out of memory */
>  	new_page = mem_map + MAP_NR(new_page_addr);

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

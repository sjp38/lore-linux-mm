Subject: Re: [PATCH] add PF_MEMALLOC to __alloc_pages()
References: <Pine.LNX.4.21.0101031258070.1403-100000@duckman.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 04 Jan 2001 00:03:13 +0100
In-Reply-To: Rik van Riel's message of "Wed, 3 Jan 2001 13:03:27 -0200 (BRDT)"
Message-ID: <87g0j0qlvy.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mike Galbraith <mikeg@wen-online.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> Hi Linus, Alan, Mike,
> 
> the following patch sets PF_MEMALLOC for the current task
> in __alloc_pages() to avoid infinite recursion when we try
> to free memory from __alloc_pages().
> 
> Please apply the patch below, which fixes this (embarrasing)
> bug...
> 
[snip]
>  		 * free ourselves...
>  		 */
>  		} else if (gfp_mask & __GFP_WAIT) {
> +			current->flags |= PF_MEMALLOC;
>  			try_to_free_pages(gfp_mask);
> +			current->flags &= ~PF_MEMALLOC;
>  			memory_pressure++;
>  			if (!order)
>  				goto try_again;
> 

Hm, try_to_free_pages already sets the PF_MEMALLOC flag!
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

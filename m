Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH] Avoid !__GFP_IO allocations to eat from memory reservations
Date: Thu, 14 Jun 2001 19:17:48 +0200
References: <20010614143441Z263016-17720+3764@vger.kernel.org>
In-Reply-To: <20010614143441Z263016-17720+3764@vger.kernel.org>
MIME-Version: 1.0
Message-Id: <01061419174808.00879@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thursday 14 June 2001 14:59, Marcelo Tosatti wrote:
> --- linux/mm/page_alloc.c.orig	Thu Jun 14 11:00:14 2001
> +++ linux/mm/page_alloc.c	Thu Jun 14 11:32:56 2001
> @@ -453,6 +453,12 @@
>  				int progress = try_to_free_pages(gfp_mask);
>  				if (progress || gfp_mask & __GFP_IO)
>  					goto try_again;
> +				/*
> +				 * Fail in case no progress was made and the
> +				 * allocation may not be able to block on IO.
> +				 */
> +				else
> +					return NULL;
>  			}
>  		}
>  	}

Nitpick dept: the 'else' is redundant.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

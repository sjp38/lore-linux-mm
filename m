Date: Wed, 22 Aug 2001 21:40:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH NG] alloc_pages_limit & pages_min
In-Reply-To: <200108222350.f7MNoZp17510@maild.telia.com>
Message-ID: <Pine.LNX.4.33L.0108222139350.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2001, Roger Larsson wrote:

> +				if (page) {
> +					while (z->free_pages < z->pages_low) {
> +						struct page *extra = reclaim_page(z);
> +						if (!extra)
> +							break;
> +						__free_page(extra);
> +					}
> +				}

This is a surprise ;)

Why did you introduce this piece of code?
What is it supposed to achieve ?

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Thu, 5 Apr 2001 13:05:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.30.0104051155380.1767-100000@today.toronto.redhat.com>
Message-ID: <Pine.LNX.4.21.0104051304450.27736-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: arjanv@redhat.com, alan@redhat.com, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2001, Ben LaHaise wrote:

> Here's another one liner that closes an smp race that could corrupt
> things.

> -	if (PageSwapCache(page) && !TryLockPage(page)) {
> +	if (!TryLockPage(page) && PageSwapCache(page)) {
>  		if (!is_page_shared(page)) {
>  			delete_from_swap_cache_nolock(page);
>  		}

I sure hope the page is unlocked afterwards, regardless of
whether it's (still) in the swap cache or not ...

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

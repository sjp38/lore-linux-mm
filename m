Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 0F06438C96
	for <linux-mm@kvack.org>; Wed,  8 Aug 2001 16:11:13 -0300 (EST)
Date: Wed, 8 Aug 2001 16:11:12 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swapping anonymous pages
In-Reply-To: <200108081729.f78HTvY06100@srcintern6.pa.dec.com>
Message-ID: <Pine.LNX.4.33L.0108081603400.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keir Fraser <fraser@pa.dec.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2001, Keir Fraser wrote:

> The only reasons I can see for doing the current way are:
>  * keeping the reverse (physical -> virtual) mappings would eat too
>    much memory.
>  * since it's old (pre-2.4) code, perhaps noone has yet got round to
>    rewriting it for the new design.
>
> So, I'm curious to know which of the two it is (or whether the current
> way was found to be "good enough").

Both ;)

Even without the reverse mapping overhead (8 bytes per
pte for shared pages in my current implementation) we
have FAR too much pagetable overhead on large memory
machines anyway.

This means we need to support 2MB / 4MB pages, after
which the point about reverse mappings being too much
overhead pretty much becomes moot...

I'm planning to implement some of this stuff for 2.5.

regards,

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Wed, 15 Aug 2001 20:38:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108152343460.972-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.33L.0108152036040.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Aug 2001, Hugh Dickins wrote:

> 1. Why test free_shortage() in the high-order case?  The caller has
>    asked for a high-order allocation, and is prepared to wait: we
>    haven't found what the caller needs yet, we certainly should not
>    wait forever, but we should try harder: it's irrelevant whether
>    there's a free shortage or not - we've found a contiguity shortage.

It may be irrelevant, but remember that try_to_free_pages()
doesn't free any pages if there is no free shortage.

Besides, even if it did chances are you wouldn't be able
to allocate that 2MB contiguous area any time next week ;)

> 3. Allocation failure message would do well to show gfp_mask too.

Agreed, gfp_mask and PF_MEMALLOC would be useful things
to know here...

regards,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Sat, 9 Jun 2001 04:46:36 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
In-Reply-To: <l0313030fb743f99e010e@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106090444510.14934-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Andrew Morton <andrewm@uow.edu.au>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2001, Jonathan Morton wrote:

> >> BUT, as it turns out, refill_inactive_scan() already does ageing down on a
> >> page-by-page basis, rather than process-by-process.
> >
> >Yes.  page->count needs looking at if you're doing physically-addressed
> >scanning.  Rik's patch probably does that.
> 
> Explain...
> 
> AFAICT, the scanning in refill_inactive_scan() simply looks at a list
> of pages, and doesn't really do physical addresses.

http://www.surriel.com/patches/2.4/2.4.5-ac5-pmap

In this patch, the kernel looks at the page table entries
using a page from refill_inactive() and does its page aging
on a per-physical-page basis.

Of course, this costs us some overhead and I'm not at all
convinced we actually want to use this strategy. It's just
too much fun to code to not try ;)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Date: Thu, 20 Feb 2003 14:19:39 -0300 (BRT)
From: Rik van Riel <riel@imladris.surriel.com>
Subject: Re: [PATCH 2.5.62] Partial object-based rmap implementation
In-Reply-To: <8390000.1045757611@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.50L.0302201415070.2329-100000@imladris.surriel.com>
References: <8390000.1045757611@baldur.austin.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.50L.0302201415072.2329@imladris.surriel.com>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Feb 2003, Dave McCracken wrote:

> There's been a fair amount of discussion about the advantages of doing
> object-based rmap.

Unfortunately, not nearly as much about the disadvantages.

There are big advantages and disadvantages to both ways of
doing reverse mappings. I'm planning to write about both
for my OLS paper and analise the algorithmic complexities
in more detail so we've got a better idea of exactly what
we're facing.

> I've been looking into it, and we have the pieces to
> do it for file-backed objects, ie the ones that have a real
> address_space object pointed to from struct page.  The stumbling block
> has always been anonymous pages.

And algorithmic complexities, for some reason those always seem
to be about as unexpected as the Spanish Inquisition. ;)

> At Martin Bligh's suggestion, I coded up an object-based implementation for
> non-anon pages while leaving the pte_chain code intact for anon pages.  My
> fork/exit microbenchmark shows roughly 50% improvement for tasks that are
> composes of file-backed and/or shared pages.  This is the code that Martin
> included in 2.5.62-mjb2 and reported his performance results on.

But how is performance under memory pressure ?

> Anyway, here's the patch if anyone wants to check it out.

It's nice, but we'll want to find a way to alleviate some of the
worst case complexities.   Definately something worth exploring
further.

It would be good to discuss the pitfalls of object based reverse
mapping with Ben LaHaise and Dave Miller, who have implemented
such schemes in the past.

kind regards,

Rik
-- 
Engineers don't grow up, they grow sideways.
http://www.surriel.com/		http://kernelnewbies.org/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

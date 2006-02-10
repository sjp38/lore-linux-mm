From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
Date: Fri, 10 Feb 2006 15:14:39 +1100
References: <200602101355.41421.kernel@kolivas.org> <200602101449.59486.kernel@kolivas.org> <43EC1164.4000605@yahoo.com.au>
In-Reply-To: <43EC1164.4000605@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602101514.40140.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 10 February 2006 15:07, Nick Piggin wrote:
> Con Kolivas wrote:
> > On Friday 10 February 2006 14:25, Andrew Morton wrote:
> >>But where does it put the pages?  If it was really "free", they'd go onto
> >>the tail of the inactive list.
> >
> > It puts them in swapcache. This seems to work nicely as a nowhere-land
> > place where they don't have much affect on anything until we need them or
> > need more ram. This has worked well, but I'm open to other suggestions.
>
> Well they go on the head of the inactive list and will kick out file
> backed pagecache. Which was my concern about reducing the usefulness
> of useful swapping on desktop systems.

Ok I see. We don't have a way to add to the tail of that list though? Is that 
a worthwhile addition to this (ever growing) project? That would definitely 
have an impact on the other code if not all done within swap_prefetch.c.. 
which would also be quite a large open coded something.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

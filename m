Date: Thu, 18 Aug 2005 09:17:24 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: pagefault scalability patches
In-Reply-To: <430448F8.3090502@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0508180916260.25946@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <4303EBC2.4030603@yahoo.com.au>
 <430448F8.3090502@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Nick Piggin wrote:

> Nick Piggin wrote:
> 
> > If the big ticket item is taking the ptl out of the anonymous fault
> > path, then we probably should forget my stuff
> 
> ( for now :) )

I think we can gradually work atomic operations into various code paths 
where this will be advantageous and your work may be a very important base 
to get there.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

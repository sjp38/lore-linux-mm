Date: Fri, 30 Jan 2004 07:04:57 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [BENCHMARKS] 2.6 kbuild results (with add_to_swap patch)
In-Reply-To: <4019C729.8050505@cyberone.com.au>
Message-ID: <Pine.LNX.4.44.0401300704130.20553-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Nikita Danilov <Nikita@Namesys.COM>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jan 2004, Nick Piggin wrote:

> Small big significantly better on kbuild when tested on top of the other
> two patches (dont-rotate-active-list and my mapped-fair).

Where can I grab those ?

> With this patch as well, we are now as good or better than 2.4 on
> medium and heavy swapping kbuilds and much better than stock 2.6
> with light swapping loads (not as good as 2.4 but close).
> 
> http://www.kerneltrap.org/~npiggin/vm/3/

Neat!  Does it have any side effects to interactive
desktop behaviour ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Fri, 12 Dec 2003 21:32:26 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Non-Contiguous Memory Allocation Tests
In-Reply-To: <200312091111.21349.ruthiano@exatas.unisinos.br>
Message-ID: <Pine.LNX.4.44.0312122130590.26386-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0312122130592.26386@chimarrao.boston.redhat.com>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ruthiano Simioni Munaretti <ruthiano@exatas.unisinos.br>
Cc: linux-mm@kvack.org, sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 2003, Ruthiano Simioni Munaretti wrote:

> Our patch is intended to be a test to check if this could bring enough 
> benefits to deserve a more careful implementation. We also included some code 
> to benchmark allocations and deallocations, using the RDTSC instruction.

I doubt it.  The vmalloc code path should not be used very
often at all in the kernel and for userspace allocations the
bigger overhead will probably be in things like setting up
page tables and zeroing out the pages.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

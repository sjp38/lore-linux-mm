Date: Tue, 28 Nov 2006 19:32:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <456D0757.6050903@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <456D0757.6050903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Nick Piggin wrote:

> Christoph Lameter wrote:
> > This patch replaces all uses of kmem_cache_t with struct kmem_cache.
> kmem_cache really is an opaque type outside of mm/slab.c, isn't it?

kmem_cache_t would require a declaration. struct kmem_cache * can be used 
without a prior declaration in include files. Please review the earlier 
discussion on linux-mm regarding the removal of the global slab caches 
from <linux/slab.h>.

Frankly the maintenance of the opaque type here has caused us enough grief 
over the years. I would like to get rid of it in the future and declare 
the contents of struct kmem_cache in slab.h. That will allow us to 
simplify the slab bootstrap and make it easier to understand. One 
reason slab bootstrap is so complex because one cannot simple do a static 
declaration of a struct kmem_cache and start off with it. See the earlier 
discussion with Matt Mackall on the slabifier design.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

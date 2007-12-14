From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 04/29] mm: kmem_estimate_pages()
Date: Fri, 14 Dec 2007 14:05:38 -0800
References: <20071214153907.770251000@chello.nl> <20071214154439.489413000@chello.nl>
In-Reply-To: <20071214154439.489413000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712141405.38577.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Friday 14 December 2007 07:39, Peter Zijlstra wrote:
> Provide a method to get the upper bound on the pages needed to
> allocate a given number of objects from a given kmem_cache.
>
> This lays the foundation for a generic reserve framework as presented
> in a later patch in this series. This framework needs to convert
> object demand (kmalloc() bytes, kmem_cache_alloc() objects) to pages.

And hence the big idea that all reserve accounting can be done in units
of pages, allowing the use of a single global reserve that already 
exists.

The other big idea here is that reserve accounting can be independent of 
the actual resource allocations.  This is a powerful idea which we may 
not have explained clearly yet.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: [patch 5/5] slub: Large allocs for other slab sizes that do not fit in order 0
In-Reply-To: <20080214040314.388752493@sgi.com>
Message-ID: <x46V2RJW.1202973265.1848000.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Thu, 14 Feb 2008 09:14:25 +0200 (EET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 2/14/2008, "Christoph Lameter" <clameter@sgi.com> wrote:
> Expand the scheme used for kmalloc-2048 and kmalloc-4096 to all slab
> caches. That means that kmem_cache_free() must now be able to 
> handle a fallback object that was allocated from the page allocator. This is
> touching the fastpath costing us 1/2 % of performance (pretty small
> so within variance). Kind of hacky though.

Looks good but are there any numbers that indicate this is an overall win?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 3 Apr 2002 14:32:28 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Slab allocator - questions
Message-ID: <20020403143227.A6301@redhat.com>
References: <3CAAC471.ED65E4C9@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3CAAC471.ED65E4C9@scs.ch>; from maletinsky@scs.ch on Wed, Apr 03, 2002 at 10:59:29AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, Apr 03, 2002 at 10:59:29AM +0200, Martin Maletinsky wrote:
...
> 2) Why are there general caches up to a size of 128K byte? Since a slab 
> consists of physically contiguous pages, one might call right into the 
> buddy system to get chunks of memory that are a multiple of a page size. 
> What is the benefit of allocating memory chunks that are a multiple of 
> a page size by using kmalloc()/kmem_cache_alloc() rather than
> get_free_pages?

Memory fragmentation.  By grouping objects of the same type and similar 
lifetimes, slab helps prevent the pinning of many individual pages across 
the system.  Since slab allocations cannot be relocated, this helps when 
other allocations need to obtain non-0 order pages.

> 3) How does the slab cache allocator deal with high memory pages in 2.4.x 
> (i.e. pages for which no KSEG address exists)?

They are not used.

		-ben
-- 
"A man with a bass just walked in,
 and he's putting it down
 on the floor."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

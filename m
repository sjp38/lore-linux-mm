Date: Tue, 24 Apr 2007 23:21:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
In-Reply-To: <1177462288.1281.11.camel@dyn9047017100.beaverton.ibm.com>
Message-ID: <Pine.LNX.4.64.0704242321310.21125@schroedinger.engr.sgi.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
 <1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com>
 <20070424155151.644e88b7.akpm@linux-foundation.org>
 <1177462288.1281.11.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007, Badari Pulavarty wrote:

> static inline struct kmem_cache *kmalloc_slab(size_t size)
> {
>         int index = kmalloc_index(size);
> 
>         if (index == 0)
>                 return NULL;
> 
>         if (index < 0) {
>                 /*
>                  * Generate a link failure. Would be great if we could
>                  * do something to stop the compile here.
>                  */
>                 extern void __kmalloc_size_too_large(void);
>                 __kmalloc_size_too_large();
>         }
>         return &kmalloc_caches[index];
> }
> 
> hmm.. 
> 
> gcc version 3.3.3 -- generates those link failures
> gcc version 4.1.0 -- doesn't generate this error

Likely an issue with constant folding.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

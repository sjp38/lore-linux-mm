Date: Tue, 24 Jul 2007 16:59:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
Message-Id: <20070724165914.a5945763.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007 22:48:03 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> Slab constructors currently have a flags parameter that is never used. And
> the order of the arguments is opposite to other slab functions. The object
> pointer is placed before the kmem_cache pointer.
> 
> Convert
> 
> 	ctor(void *object, struct kmem_cache *s, unsigned long flags)
> 
> to
> 
> 	ctor(struct kmem_cache *s, void *object)
> 
> throughout the kernel

arch/i386/mm/pgtable.c:197: error: conflicting types for 'pmd_ctor'
include/asm/pgtable.h:43: error: previous declaration of 'pmd_ctor' was here
make[1]: *** [arch/i386/mm/pgtable.o] Error 1
make: *** [arch/i386/mm/pgtable.o] Error 2
make: *** Waiting for unfinished jobs....
fs/locks.c: In function 'filelock_init':
fs/locks.c:2276: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
mm/rmap.c: In function 'anon_vma_init':
mm/rmap.c:151: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
fs/inode.c: In function 'inode_init':
fs/inode.c:1391: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
mm/shmem.c: In function 'init_inodecache':
mm/shmem.c:2344: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
fs/block_dev.c: In function 'bdev_cache_init':
fs/block_dev.c:532: warning: passing argument 5 of 'kmem_cache_create' from incompatible pointer type
make: *** wait: No child processes.  Stop.


I might let these patches cook a little longer.

Now is the 100% worst time to merge this sort of thing btw: I get to carry
it for two months while the world churns.  Around the -rc7 timeframe would 
be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

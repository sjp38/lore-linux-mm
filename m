Date: Mon, 4 Feb 2008 14:28:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [git pull] SLUB updates for 2.6.25
Message-Id: <20080204142845.4c734f94.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Feb 2008 12:08:34 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Updates for slub are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slub-linus
> 
> Christoph Lameter (5):
>       SLUB: Fix sysfs refcounting
>       Move count_partial before kmem_cache_shrink
>       SLUB: rename defrag to remote_node_defrag_ratio
>       Add parameter to add_partial to avoid having two functions
>       Explain kmem_cache_cpu fields
> 
> Harvey Harrison (1):
>       slub: fix shadowed variable sparse warnings
> 
> Pekka Enberg (1):
>       SLUB: Fix coding style violations
> 
> root (1):
>       SLUB: Do not upset lockdep
> 

err, what?  I though I was going to merge these:

slub-move-count_partial.patch
slub-rename-numa-defrag_ratio-to-remote_node_defrag_ratio.patch
slub-consolidate-add_partial-and-add_partial_tail-to-one-function.patch
slub-use-non-atomic-bit-unlock.patch
slub-fix-coding-style-violations.patch
slub-noinline-some-functions-to-avoid-them-being-folded-into-alloc-free.patch
slub-move-kmem_cache_node-determination-into-add_full-and-add_partial.patch
slub-avoid-checking-for-a-valid-object-before-zeroing-on-the-fast-path.patch
slub-__slab_alloc-exit-path-consolidation.patch
slub-provide-unique-end-marker-for-each-slab.patch
slub-avoid-referencing-kmem_cache-structure-in-__slab_alloc.patch
slub-optional-fast-path-using-cmpxchg_local.patch
slub-do-our-own-locking-via-slab_lock-and-slab_unlock.patch
slub-restructure-slab-alloc.patch
slub-comment-kmem_cache_cpu-structure.patch
slub-fix-sysfs-refcounting.patch

before you went and changed things under my feet.

Please clarify.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

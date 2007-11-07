Date: Wed, 7 Nov 2007 03:37:09 +0100
From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [patch 09/23] SLUB: Add get() and kick() methods
Message-ID: <20071107023709.GU26163@stusta.de>
References: <20071107011130.382244340@sgi.com> <20071107011228.605750914@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20071107011228.605750914@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 06, 2007 at 05:11:39PM -0800, Christoph Lameter wrote:
> Add the two methods needed for defragmentation and add the display of the
> methods via the proc interface.
> 
> Add documentation explaining the use of these methods.
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  include/linux/slab.h     |    3 +++
>  include/linux/slub_def.h |   31 +++++++++++++++++++++++++++++++
>  mm/slub.c                |   32 ++++++++++++++++++++++++++++++--
>  3 files changed, 64 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/include/linux/slab.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slab.h	2007-10-17 13:35:53.000000000 -0700
> +++ linux-2.6/include/linux/slab.h	2007-11-06 12:37:51.000000000 -0800
> @@ -56,6 +56,9 @@ struct kmem_cache *kmem_cache_create(con
>  			void (*)(struct kmem_cache *, void *));
>  void kmem_cache_destroy(struct kmem_cache *);
>  int kmem_cache_shrink(struct kmem_cache *);
> +void kmem_cache_setup_defrag(struct kmem_cache *s,
> +	void *(*get)(struct kmem_cache *, int nr, void **),
> +	void (*kick)(struct kmem_cache *, int nr, void **, void *private));
>  void kmem_cache_free(struct kmem_cache *, void *);
>  unsigned int kmem_cache_size(struct kmem_cache *);
>  const char *kmem_cache_name(struct kmem_cache *);
>...

A static inline dummy function for CONFIG_SLUB=n seems to be missing?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

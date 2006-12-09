Received: by ug-out-1314.google.com with SMTP id s2so930769uge
        for <linux-mm@kvack.org>; Sat, 09 Dec 2006 06:02:54 -0800 (PST)
Message-ID: <84144f020612090602w5c7f3f9ay8e771763ea8843cf@mail.gmail.com>
Date: Sat, 9 Dec 2006 16:02:53 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC] Cleanup slab headers / API to allow easy addition of new slab allocators
In-Reply-To: <Pine.LNX.4.64.0612081106320.16873@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0612081106320.16873@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 12/8/06, Christoph Lameter <clameter@sgi.com> wrote:
> +#define        SLAB_POISON             0x00000800UL    /* DEBUG: Poison objects */
> +#define        SLAB_HWCACHE_ALIGN      0x00002000UL    /* Align objs on cache lines */
> +#define SLAB_CACHE_DMA         0x00004000UL    /* Use GFP_DMA memory */
> +#define SLAB_MUST_HWCACHE_ALIGN        0x00008000UL    /* Force alignment even if debuggin is active */

Please fix formatting while you're at it.

> +#ifdef CONFIG_SLAB
> +#include <linux/slab_def.h>
> +#else
> +
> +/*
> + * Fallback definitions for an allocator not wanting to provide
> + * its own optimized kmalloc definitions (like SLOB).
> + */
> +
> +#if defined(CONFIG_NUMA) || defined(CONFIG_DEBUG_SLAB)
> +#error "SLAB fallback definitions not usable for NUMA or Slab debug"

Do we need this? Shouldn't we just make sure no one can enable
CONFIG_NUMA and CONFIG_DEBUG_SLAB for non-compatible allocators?

> -static inline void *kmalloc(size_t size, gfp_t flags)
> +void *kmalloc(size_t size, gfp_t flags)

static inline?

> +void *kzalloc(size_t size, gfp_t flags)
> +{
> +       return __kzalloc(size, flags);
> +}

same here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

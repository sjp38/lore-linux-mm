Subject: Re: [patch 3/4] cpu alloc: The allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20080929193516.278278446@quilx.com>
References: <20080929193500.470295078@quilx.com>
	 <20080929193516.278278446@quilx.com>
Date: Tue, 30 Sep 2008 09:35:59 +0300
Message-Id: <1222756559.10002.23.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rusty@rustcorp.com.au, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-29 at 12:35 -0700, Christoph Lameter wrote:
> Index: linux-2.6/mm/cpu_alloc.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6/mm/cpu_alloc.c	2008-09-29 13:09:33.000000000 -0500
> @@ -0,0 +1,185 @@
> +/*
> + * Cpu allocator - Manage objects allocated for each processor
> + *
> + * (C) 2008 SGI, Christoph Lameter <cl@linux-foundation.org>
> + * 	Basic implementation with allocation and free from a dedicated per
> + * 	cpu area.
> + *
> + * The per cpu allocator allows a dynamic allocation of a piece of memory on
> + * every processor. A bitmap is used to track used areas.
> + * The allocator implements tight packing to reduce the cache footprint
> + * and increase speed since cacheline contention is typically not a concern
> + * for memory mainly used by a single cpu. Small objects will fill up gaps
> + * left by larger allocations that required alignments.
> + */
> +#include <linux/mm.h>
> +#include <linux/mmzone.h>
> +#include <linux/module.h>
> +#include <linux/percpu.h>
> +#include <linux/bitmap.h>
> +#include <asm/sections.h>
> +#include <linux/bootmem.h>
> +
> +/*
> + * Basic allocation unit. A bit map is created to track the use of each
> + * UNIT_SIZE element in the cpu area.
> + */
> +#define UNIT_TYPE int
> +#define UNIT_SIZE sizeof(UNIT_TYPE)
> +
> +int units;	/* Actual available units */

What is this thing? Otherwise looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

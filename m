Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id DAFD96B0044
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 14:11:26 -0400 (EDT)
Date: Tue, 2 Oct 2012 18:11:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] slab: Ignore internal flags in cache creation
In-Reply-To: <1349171968-19243-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013a22acdcd4-ba2fbe44-ae66-4b10-86fa-d49d907d9dda-000000@email.amazonses.com>
References: <1349171968-19243-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 2 Oct 2012, Glauber Costa wrote:

>  #include <linux/kmemleak.h>
>
> +#define SLAB_AVAILABLE_FLAGS	0xFFFFFFFFUL /* No flag restriction */
> +
>  enum stat_item {

I thought the SLAB_AVAILABLE_FLAGS would stand for something meaningful
like the flags supported by an allocator given a kernel config. F.e. SLUB
does not support the debug flags if not compiled with debug.

This looks like it could become material that would fit in mm/slab.h.
There are sets of flags that all allocators have to support (RCU, DMA etc)
and others (like the debug flags) that are optional.

Slob also supports some flags but never any of the debug flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

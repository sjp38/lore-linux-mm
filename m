Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8E6BD6B003B
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 14:00:51 -0500 (EST)
Date: Mon, 4 Feb 2013 19:00:50 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH for-next] mm/sl[au]b: correct allocation type check in
 kmalloc_slab()
In-Reply-To: <1359989206-16116-1-git-send-email-js1304@gmail.com>
Message-ID: <0000013ca69506df-e0ec43f2-9320-4d11-b70a-de61cdcc84aa-000000@email.amazonses.com>
References: <20130202125952.GE16114@localhost> <1359989206-16116-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, 4 Feb 2013, Joonsoo Kim wrote:

> commit "slab: Common Kmalloc cache determination" made mistake
> in kmalloc_slab(). SLAB_CACHE_DMA is for kmem_cache creation,
> not for allocation. For allocation, we should use GFP_XXX to identify
> type of allocation. So, change SLAB_CACHE_DMA to GFP_DMA.

Correct.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

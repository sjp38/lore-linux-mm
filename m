Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC8E6B005C
	for <linux-mm@kvack.org>; Tue, 26 May 2009 15:17:44 -0400 (EDT)
Subject: Re: [PATCH] drm: i915: ensure objects are allocated below 4GB on
 PAE
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090526162717.GC14808@bombadil.infradead.org>
References: <20090526162717.GC14808@bombadil.infradead.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 26 May 2009 21:17:53 +0200
Message-Id: <1243365473.23657.32.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: airlied@redhat.com, dri-devel@lists.sf.net, linux-kernel@vger.kernel.org, jbarnes@virtuousgeek.org, eric@anholt.net, stable@kernel.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, shaohua.li@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2009-05-26 at 12:27 -0400, Kyle McMartin wrote:
> From: Kyle McMartin <kyle@redhat.com>
> 
> Ensure we allocate GEM objects below 4GB on PAE machines, otherwise
> misery ensues. This patch is based on a patch found on dri-devel by
> Shaohua Li, but Keith P. expressed reticence that the changes unfairly
> penalized other hardware.
> 
> (The mm/shmem.c hunk is necessary to ensure the DMA32 flag isn't used
>  by the slab allocator via radix_tree_preload, which will hit a
>  WARN_ON.)

Why is this, is the gart not PAE friendly?

Seems to me its a grand way of promoting 64bit hard/soft-ware.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8A27482F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 08:28:20 -0500 (EST)
Received: by pasz6 with SMTP id z6so91332146pas.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 05:28:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pn6si8428022pbb.43.2015.11.05.05.28.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 05:28:19 -0800 (PST)
Date: Thu, 5 Nov 2015 05:31:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: slab: Only move management objects off-slab for
 sizes larger than KMALLOC_MIN_SIZE
Message-Id: <20151105053139.e38214a9.akpm@linux-foundation.org>
In-Reply-To: <1446724235-31400-1-git-send-email-catalin.marinas@arm.com>
References: <20151105043155.GA20374@js1304-P5Q-DELUXE>
	<1446724235-31400-1-git-send-email-catalin.marinas@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Geert Uytterhoeven <geert@linux-m68k.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu,  5 Nov 2015 11:50:35 +0000 Catalin Marinas <catalin.marinas@arm.com> wrote:

> Commit 8fc9cf420b36 ("slab: make more slab management structure off the
> slab") enables off-slab management objects for sizes starting with
> PAGE_SIZE >> 5. This means 128 bytes for a 4KB page configuration.
> However, on systems with a KMALLOC_MIN_SIZE of 128 (arm64 in 4.4), such
> optimisation does not make sense since the slab management allocation
> would take 128 bytes anyway (even though freelist_size is 32) with the
> additional overhead of another allocation.
> 
> This patch introduces an OFF_SLAB_MIN_SIZE macro which takes
> KMALLOC_MIN_SIZE into account. It also solves a slab bug on arm64 where
> the first kmalloc_cache to be initialised after slab_early_init = 0,
> "kmalloc-128", fails to allocate off-slab management objects from the
> same "kmalloc-128" cache.

That all seems to be quite minor stuff.

> Fixes: 8fc9cf420b36 ("slab: make more slab management structure off the slab")
> Cc: <stable@vger.kernel.org> # 3.15+

Yet you believe the fix should be backported.

So, the usual refrain: when fixing a bug, please describe the end-user
visible effects of that bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

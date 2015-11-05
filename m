Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBC282F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 12:39:49 -0500 (EST)
Received: by ioll68 with SMTP id l68so98812709iol.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 09:39:49 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id 41si7451709iop.200.2015.11.05.09.39.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 09:39:49 -0800 (PST)
Date: Thu, 5 Nov 2015 11:39:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: slab: Only move management objects off-slab for
 sizes larger than KMALLOC_MIN_SIZE
In-Reply-To: <1446724235-31400-1-git-send-email-catalin.marinas@arm.com>
Message-ID: <alpine.DEB.2.20.1511051139220.28479@east.gentwo.org>
References: <20151105043155.GA20374@js1304-P5Q-DELUXE> <1446724235-31400-1-git-send-email-catalin.marinas@arm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Geert Uytterhoeven <geert@linux-m68k.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 5 Nov 2015, Catalin Marinas wrote:

> This patch introduces an OFF_SLAB_MIN_SIZE macro which takes
> KMALLOC_MIN_SIZE into account. It also solves a slab bug on arm64 where
> the first kmalloc_cache to be initialised after slab_early_init = 0,
> "kmalloc-128", fails to allocate off-slab management objects from the
> same "kmalloc-128" cache.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

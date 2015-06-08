Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id BDA2B6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 05:38:15 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so57087806igb.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 02:38:15 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id e42si1582806ioj.105.2015.06.08.02.38.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 02:38:15 -0700 (PDT)
Date: Mon, 8 Jun 2015 04:38:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case
In-Reply-To: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
Message-ID: <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org>
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liu, XinwuX" <xinwux.liu@intel.com>
Cc: "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

On Mon, 8 Jun 2015, Liu, XinwuX wrote:

> when kernel uses kmalloc to allocate memory, slub/slab will find
> a suitable kmem_cache. Ususally the cache's object size is often
> greater than requested size. There is unused space which contains
> dirty data. These dirty data might have pointers pointing to a block

dirty? In what sense?

> of leaked memory. Kernel wouldn't consider this memory as leaked when
> scanning kmemleak object.

This has never been considered leaked memory before to my knowledge and
the data is already initialized.

F.e. The zeroing function in linux/mm/slub.c::slab_alloc_node() zeros the
complete object and not only the number of bytes specified in the kmalloc
call. Same thing is true for SLAB.

I am a bit confused as to what issue this patch would address.

Also please send clean patches without special characters. Ensure proper
tabbing etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

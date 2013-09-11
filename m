Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id A1FC16B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:30:04 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:30:03 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 01/16] slab: correct pfmemalloc check
In-Reply-To: <1377161065-30552-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <000001410d6dd2ea-858fd952-3568-44e9-ac6a-070810b732d0-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> And, therefore we should check pfmemalloc in page flag of first page,
> but current implementation don't do that. virt_to_head_page(obj) just
> return 'struct page' of that object, not one of first page, since the SLAB
> don't use __GFP_COMP when CONFIG_MMU. To get 'struct page' of first page,
> we first get a slab and try to get it via virt_to_head_page(slab->s_mem).

Maybe using __GFP_COMP would make it consistent across all allocators and
avoid the issue? We then do only have to set the flags on the first page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

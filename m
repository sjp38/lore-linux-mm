Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44C9F6B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:38:49 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r94so250977239ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 08:38:49 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id 192si19402992itl.125.2016.11.28.08.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 08:38:48 -0800 (PST)
Date: Mon, 28 Nov 2016 10:38:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
In-Reply-To: <20161128162126.ulbqrslpahg4wdk3@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1611281037400.29533@east.gentwo.org>
References: <20161127131954.10026-1-mgorman@techsingularity.net> <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org> <20161128162126.ulbqrslpahg4wdk3@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Mon, 28 Nov 2016, Mel Gorman wrote:

> Yes, that's a problem for SLUB with or without this patch. It's always
> been the case that SLUB relying on high-order pages for performance is
> problematic.

This is a general issue in the kernel. Performance often requires larger
contiguous ranges of memory.


> > that only insiders know how to tune and an overall fragile solution.
> While I agree with all of this, it's also a problem independent of this
> patch.

It is related. The fundamental issue with fragmentation remain and IMHO we
really need to tackle this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

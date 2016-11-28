Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDCA76B0253
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:53:57 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id t93so258258961ioi.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:53:57 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id p71si19803111itp.87.2016.11.28.10.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 10:53:57 -0800 (PST)
Date: Mon, 28 Nov 2016 12:54:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
In-Reply-To: <20161128184758.bcz5ar5svv7whnqi@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1611281251150.30514@east.gentwo.org>
References: <20161127131954.10026-1-mgorman@techsingularity.net> <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org> <20161128162126.ulbqrslpahg4wdk3@techsingularity.net> <alpine.DEB.2.20.1611281037400.29533@east.gentwo.org>
 <20161128184758.bcz5ar5svv7whnqi@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Mon, 28 Nov 2016, Mel Gorman wrote:

> If you have a series aimed at parts of the fragmentation problem or how
> subsystems can avoid tracking 4K pages in some important cases then by
> all means post them.

I designed SLUB with defrag methods in mind. We could warm up some old
patchsets that where never merged:

https://lkml.org/lkml/2010/1/29/332

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

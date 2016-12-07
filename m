Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47CE66B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 09:52:32 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t31so287730158ioi.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 06:52:32 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id v126si17550994ioe.252.2016.12.07.06.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 06:52:31 -0800 (PST)
Date: Wed, 7 Dec 2016 08:52:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
In-Reply-To: <20161207101228.8128-1-mgorman@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, 7 Dec 2016, Mel Gorman wrote:

> SLUB has been the default small kernel object allocator for quite some time
> but it is not universally used due to performance concerns and a reliance
> on high-order pages. The high-order concerns has two major components --

SLUB does not rely on high order pages. It falls back to lower order if
the higher orders are not available. Its a performance concern.

This is also an issue for various other kernel subsystems that really
would like to have larger contiguous memory area. We are often seeing
performance constraints due to the high number of 4k segments when doing
large scale block I/O f.e.

Otherwise I really like what I am seeing here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id F17546B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 12:11:12 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j92so299615211ioi.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 09:11:12 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id d76si6749903ith.0.2016.12.07.09.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 09:11:12 -0800 (PST)
Date: Wed, 7 Dec 2016 11:11:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
In-Reply-To: <20161207164554.b73qjfxy2w3h3ycr@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1612071109160.11056@east.gentwo.org>
References: <20161207101228.8128-1-mgorman@techsingularity.net> <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org> <20161207155750.yfsizliaoodks5k4@techsingularity.net> <alpine.DEB.2.20.1612071037480.11056@east.gentwo.org>
 <20161207164554.b73qjfxy2w3h3ycr@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, 7 Dec 2016, Mel Gorman wrote:

> 3.0-era kernels had better fragmentation control, higher success rates at
> allocation etc. I vaguely recall that it had fewer sources of high-order
> allocations but I don't remember specifics and part of that could be the
> lack of THP at the time. The overhead was massive due to massive stalls
> and excessive reclaim -- hours to complete some high-allocation stress
> tests even if the success rate was high.

There were a couple of high order page reclaim improvements implemented
at that time that were later abandoned. I think higher order pages were
more available than now. SLUB was regularly able to get higher order pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

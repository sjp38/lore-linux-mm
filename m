Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E914D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 11:40:50 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r94so295596467ioe.7
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 08:40:50 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id 14si17909593iop.78.2016.12.07.08.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 08:40:50 -0800 (PST)
Date: Wed, 7 Dec 2016 10:40:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
In-Reply-To: <20161207155750.yfsizliaoodks5k4@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1612071037480.11056@east.gentwo.org>
References: <20161207101228.8128-1-mgorman@techsingularity.net> <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org> <20161207155750.yfsizliaoodks5k4@techsingularity.net>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, 7 Dec 2016, Mel Gorman wrote:

> Which is related to the fundamentals of fragmentation control in
> general. At some point there will have to be a revisit to get back to
> the type of reliability that existed in 3.0-era without the massive
> overhead it incurred. As stated before, I agree it's important but
> outside the scope of this patch.

What reliability issues are there? 3.X kernels were better in what
way? Which overhead are we talking about?

Fragmentation has been a problem for a long time and the issue gets worse
as memory sizes increase, the hardware improves and the expectations on
throughput and reliability increase.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

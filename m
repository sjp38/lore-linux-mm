Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC1596B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:05:12 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id z187so7641825iod.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:05:12 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id x1si29458135plb.36.2016.12.08.08.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:05:12 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id x23so27235696pgx.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:05:11 -0800 (PST)
Message-ID: <1481213050.4930.102.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Dec 2016 08:04:10 -0800
In-Reply-To: <20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
	 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20161207194801.krhonj7yggbedpba@techsingularity.net>
	 <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
	 <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
	 <20161208092231.55c7eacf@redhat.com>
	 <20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, 2016-12-08 at 09:18 +0000, Mel Gorman wrote:

> Yes, I set it for higher speed networks as a starting point to remind me
> to examine rmem_default or socket configurations if any significant packet
> loss is observed.

Note that your page allocators changes might show more impact with
netperf and af_unix (instead of udp)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

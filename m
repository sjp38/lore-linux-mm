Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B01716B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 03:26:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so9810001wmu.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 00:26:52 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id gw1si24463863wjb.102.2016.08.09.00.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 00:26:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id C6F581C1B4E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 08:26:50 +0100 (IST)
Date: Tue, 9 Aug 2016 08:26:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm/page_alloc: fix wrong initialization when
 sysctl_min_unmapped_ratio changes
Message-ID: <20160809072639.GA8119@techsingularity.net>
References: <1470724248-26780-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1470724248-26780-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, Aug 09, 2016 at 03:30:47PM +0900, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Before resetting min_unmapped_pages, we need to initialize
> min_unmapped_pages rather than min_slab_pages.
> 
> Fixes: a5f5f91da6 (mm: convert zone_reclaim to node_reclaim)
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A2B2B6B02B9
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 18:47:15 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so127501564pdr.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:47:15 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id i6si46341516pat.204.2015.07.21.15.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 15:47:14 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so127501412pdr.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:47:14 -0700 (PDT)
Date: Tue, 21 Jul 2015 15:47:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: rename and move get/set_freepage_migratetype
In-Reply-To: <1437483218-18703-2-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1507211547000.3833@chino.kir.corp.google.com>
References: <55969822.9060907@suse.cz> <1437483218-18703-1-git-send-email-vbabka@suse.cz> <1437483218-18703-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "minkyung88.kim" <minkyung88.kim@lge.com>, kmk3210@gmail.com, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 21 Jul 2015, Vlastimil Babka wrote:

> The pair of get/set_freepage_migratetype() functions are used to cache
> pageblock migratetype for a page put on a pcplist, so that it does not have
> to be retrieved again when the page is put on a free list (e.g. when pcplists
> become full). Historically it was also assumed that the value is accurate for
> pages on freelists (as the functions' names unfortunately suggest), but that
> cannot be guaranteed without affecting various allocator fast paths. It is in
> fact not needed and all such uses have been removed.
> 
> The last remaining (but pointless) usage related to pages of freelists is in
> move_freepages(), which this patch removes.
> 
> To prevent further confusion, rename the functions to
> get/set_pcppage_migratetype() and expand their description. Since all the
> users are now in mm/page_alloc.c, move the functions there from the shared
> header.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

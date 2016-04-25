Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5936B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:17:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so39824629wme.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 04:17:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu6si23897235wjd.50.2016.04.25.04.17.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 04:17:23 -0700 (PDT)
Subject: Re: [PATCH 04/28] mm, page_alloc: Inline zone_statistics
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-5-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571DFCC2.4050405@suse.cz>
Date: Mon, 25 Apr 2016 13:17:22 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-5-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> zone_statistics has one call-site but it's a public function. Make
> it static and inline.
>
> The performance difference on a page allocator microbenchmark is;
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                      statbranch-v1r20           statinline-v1r20
> Min      alloc-odr0-1               419.00 (  0.00%)           412.00 (  1.67%)
> Min      alloc-odr0-2               305.00 (  0.00%)           301.00 (  1.31%)
> Min      alloc-odr0-4               250.00 (  0.00%)           247.00 (  1.20%)
> Min      alloc-odr0-8               219.00 (  0.00%)           215.00 (  1.83%)
> Min      alloc-odr0-16              203.00 (  0.00%)           199.00 (  1.97%)
> Min      alloc-odr0-32              195.00 (  0.00%)           191.00 (  2.05%)
> Min      alloc-odr0-64              191.00 (  0.00%)           187.00 (  2.09%)
> Min      alloc-odr0-128             189.00 (  0.00%)           185.00 (  2.12%)
> Min      alloc-odr0-256             198.00 (  0.00%)           193.00 (  2.53%)
> Min      alloc-odr0-512             210.00 (  0.00%)           207.00 (  1.43%)
> Min      alloc-odr0-1024            216.00 (  0.00%)           213.00 (  1.39%)
> Min      alloc-odr0-2048            221.00 (  0.00%)           220.00 (  0.45%)
> Min      alloc-odr0-4096            227.00 (  0.00%)           226.00 (  0.44%)
> Min      alloc-odr0-8192            232.00 (  0.00%)           229.00 (  1.29%)
> Min      alloc-odr0-16384           232.00 (  0.00%)           229.00 (  1.29%)
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

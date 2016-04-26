Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC486B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 13:32:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so18804478lfg.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:32:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t203si4426164wmg.31.2016.04.26.10.32.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 10:32:14 -0700 (PDT)
Subject: Re: [PATCH 20/28] mm, page_alloc: Shortcut watermark checks for
 order-0 pages
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-8-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571FA61D.60800@suse.cz>
Date: Tue, 26 Apr 2016 19:32:13 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-8-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> Watermarks have to be checked on every allocation including the number of
> pages being allocated and whether reserves can be accessed. The reserves
> only matter if memory is limited and the free_pages adjustment only applies
> to high-order pages. This patch adds a shortcut for order-0 pages that avoids
> numerous calculations if there is plenty of free memory yielding the following
> performance difference in a page allocator microbenchmark;
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                         optfair-v1r20             fastmark-v1r20
> Min      alloc-odr0-1               380.00 (  0.00%)           364.00 (  4.21%)
> Min      alloc-odr0-2               273.00 (  0.00%)           262.00 (  4.03%)
> Min      alloc-odr0-4               227.00 (  0.00%)           214.00 (  5.73%)
> Min      alloc-odr0-8               196.00 (  0.00%)           186.00 (  5.10%)
> Min      alloc-odr0-16              183.00 (  0.00%)           173.00 (  5.46%)
> Min      alloc-odr0-32              173.00 (  0.00%)           165.00 (  4.62%)
> Min      alloc-odr0-64              169.00 (  0.00%)           161.00 (  4.73%)
> Min      alloc-odr0-128             169.00 (  0.00%)           159.00 (  5.92%)
> Min      alloc-odr0-256             180.00 (  0.00%)           168.00 (  6.67%)
> Min      alloc-odr0-512             190.00 (  0.00%)           180.00 (  5.26%)
> Min      alloc-odr0-1024            198.00 (  0.00%)           190.00 (  4.04%)
> Min      alloc-odr0-2048            204.00 (  0.00%)           196.00 (  3.92%)
> Min      alloc-odr0-4096            209.00 (  0.00%)           202.00 (  3.35%)
> Min      alloc-odr0-8192            213.00 (  0.00%)           206.00 (  3.29%)
> Min      alloc-odr0-16384           214.00 (  0.00%)           206.00 (  3.74%)
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08E8C6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:25:45 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id sq19so26402873igc.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:25:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wa2si16767589wjc.62.2016.04.26.04.25.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:25:44 -0700 (PDT)
Subject: Re: [PATCH 06/28] mm, page_alloc: Use __dec_zone_state for order-0
 page allocation
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-7-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F5031.1080900@suse.cz>
Date: Tue, 26 Apr 2016 13:25:37 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-7-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> __dec_zone_state is cheaper to use for removing an order-0 page as it
> has fewer conditions to check.
>
> The performance difference on a page allocator microbenchmark is;
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                         optiter-v1r20              decstat-v1r20
> Min      alloc-odr0-1               382.00 (  0.00%)           381.00 (  0.26%)
> Min      alloc-odr0-2               282.00 (  0.00%)           275.00 (  2.48%)
> Min      alloc-odr0-4               233.00 (  0.00%)           229.00 (  1.72%)
> Min      alloc-odr0-8               203.00 (  0.00%)           199.00 (  1.97%)
> Min      alloc-odr0-16              188.00 (  0.00%)           186.00 (  1.06%)
> Min      alloc-odr0-32              182.00 (  0.00%)           179.00 (  1.65%)
> Min      alloc-odr0-64              177.00 (  0.00%)           174.00 (  1.69%)
> Min      alloc-odr0-128             175.00 (  0.00%)           172.00 (  1.71%)
> Min      alloc-odr0-256             184.00 (  0.00%)           181.00 (  1.63%)
> Min      alloc-odr0-512             197.00 (  0.00%)           193.00 (  2.03%)
> Min      alloc-odr0-1024            203.00 (  0.00%)           201.00 (  0.99%)
> Min      alloc-odr0-2048            209.00 (  0.00%)           206.00 (  1.44%)
> Min      alloc-odr0-4096            214.00 (  0.00%)           212.00 (  0.93%)
> Min      alloc-odr0-8192            218.00 (  0.00%)           215.00 (  1.38%)
> Min      alloc-odr0-16384           219.00 (  0.00%)           216.00 (  1.37%)
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

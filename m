Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25C746B0266
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:13:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so13437896wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:13:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e188si3521977wma.56.2016.04.26.07.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 07:13:57 -0700 (PDT)
Subject: Re: [PATCH 16/28] mm, page_alloc: Move __GFP_HARDWALL modifications
 out of the fastpath
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-4-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F77A0.2010207@suse.cz>
Date: Tue, 26 Apr 2016 16:13:52 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> __GFP_HARDWALL only has meaning in the context of cpusets but the fast path
> always applies the flag on the first attempt. Move the manipulations into
> the cpuset paths where they will be masked by a static branch in the common
> case.
>
> With the other micro-optimisations in this series combined, the impact on
> a page allocator microbenchmark is
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                         decstat-v1r20                micro-v1r20
> Min      alloc-odr0-1               381.00 (  0.00%)           377.00 (  1.05%)
> Min      alloc-odr0-2               275.00 (  0.00%)           273.00 (  0.73%)
> Min      alloc-odr0-4               229.00 (  0.00%)           226.00 (  1.31%)
> Min      alloc-odr0-8               199.00 (  0.00%)           196.00 (  1.51%)
> Min      alloc-odr0-16              186.00 (  0.00%)           183.00 (  1.61%)
> Min      alloc-odr0-32              179.00 (  0.00%)           175.00 (  2.23%)
> Min      alloc-odr0-64              174.00 (  0.00%)           172.00 (  1.15%)
> Min      alloc-odr0-128             172.00 (  0.00%)           170.00 (  1.16%)
> Min      alloc-odr0-256             181.00 (  0.00%)           183.00 ( -1.10%)
> Min      alloc-odr0-512             193.00 (  0.00%)           191.00 (  1.04%)
> Min      alloc-odr0-1024            201.00 (  0.00%)           199.00 (  1.00%)
> Min      alloc-odr0-2048            206.00 (  0.00%)           204.00 (  0.97%)
> Min      alloc-odr0-4096            212.00 (  0.00%)           210.00 (  0.94%)
> Min      alloc-odr0-8192            215.00 (  0.00%)           213.00 (  0.93%)
> Min      alloc-odr0-16384           216.00 (  0.00%)           214.00 (  0.93%)
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

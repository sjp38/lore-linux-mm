Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id A34636B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:15:04 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id os9so77515264lbb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 04:15:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 200si9689635wmj.49.2016.04.25.04.15.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 04:15:03 -0700 (PDT)
Subject: Re: [PATCH 03/28] mm, page_alloc: Reduce branches in zone_statistics
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-4-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571DFC35.6080302@suse.cz>
Date: Mon, 25 Apr 2016 13:15:01 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:58 AM, Mel Gorman wrote:
> zone_statistics has more branches than it really needs to take an
> unlikely GFP flag into account. Reduce the number and annotate
> the unlikely flag.
>
> The performance difference on a page allocator microbenchmark is;
>
>                                             4.6.0-rc2                  4.6.0-rc2
>                                      nocompound-v1r10           statbranch-v1r10
> Min      alloc-odr0-1               417.00 (  0.00%)           419.00 ( -0.48%)
> Min      alloc-odr0-2               308.00 (  0.00%)           305.00 (  0.97%)
> Min      alloc-odr0-4               253.00 (  0.00%)           250.00 (  1.19%)
> Min      alloc-odr0-8               221.00 (  0.00%)           219.00 (  0.90%)
> Min      alloc-odr0-16              205.00 (  0.00%)           203.00 (  0.98%)
> Min      alloc-odr0-32              199.00 (  0.00%)           195.00 (  2.01%)
> Min      alloc-odr0-64              193.00 (  0.00%)           191.00 (  1.04%)
> Min      alloc-odr0-128             191.00 (  0.00%)           189.00 (  1.05%)
> Min      alloc-odr0-256             200.00 (  0.00%)           198.00 (  1.00%)
> Min      alloc-odr0-512             212.00 (  0.00%)           210.00 (  0.94%)
> Min      alloc-odr0-1024            219.00 (  0.00%)           216.00 (  1.37%)
> Min      alloc-odr0-2048            225.00 (  0.00%)           221.00 (  1.78%)
> Min      alloc-odr0-4096            231.00 (  0.00%)           227.00 (  1.73%)
> Min      alloc-odr0-8192            234.00 (  0.00%)           232.00 (  0.85%)
> Min      alloc-odr0-16384           234.00 (  0.00%)           232.00 (  0.85%)
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id CD3FE6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 09:07:59 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so9392389wgb.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 06:07:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id kf4si8414072wic.48.2015.05.13.06.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 06:07:58 -0700 (PDT)
Message-ID: <55534CA2.7030105@redhat.com>
Date: Wed, 13 May 2015 09:07:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, numa: Really disable NUMA balancing by default on
 single node machines
References: <20150513081053.GQ2462@suse.de>
In-Reply-To: <20150513081053.GQ2462@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/13/2015 04:10 AM, Mel Gorman wrote:
> NUMA balancing is meant to be disabled by default on UMA machines but
> the check is using nr_node_ids (highest node) instead of num_online_nodes
> (online nodes). The consequences are that a UMA machine with a node ID of 1
> or higher will enable NUMA balancing. This will incur useless overhead due
> to minor faults with the impact depending on the workload. These are the
> impact on the stats when running a kernel build on a single node machine
> whose node ID happened to be 1;
> 
> 			       vanilla     patched
> NUMA base PTE updates          5113158           0
> NUMA huge PMD updates              643           0
> NUMA page range updates        5442374           0
> NUMA hint faults               2109622           0
> NUMA hint local faults         2109622           0
> NUMA hint local percent            100         100
> NUMA pages migrated                  0           0
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Cc: <stable@vger.kernel.org> #v3.8+

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

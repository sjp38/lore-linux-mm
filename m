Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id AD5B46B0038
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:02:52 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so187973bkb.26
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:02:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s8si8049117bkr.298.2013.12.11.01.02.51
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:02:51 -0800 (PST)
Date: Wed, 11 Dec 2013 09:02:49 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 6/8] sched/numa: fix period_slot recalculation
Message-ID: <20131211090249.GT11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-7-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386723001-25408-7-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 08:49:59AM +0800, Wanpeng Li wrote:
> Changelog:
>  v3 -> v4:
>   * remove period_slot recalculation
> 
> The original code is as intended and was meant to scale the difference
> between the NUMA_PERIOD_THRESHOLD and local/remote ratio when adjusting
> the scan period. The period_slot recalculation can be dropped.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

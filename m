Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id BCE9B6B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:01:29 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so189169bkz.15
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:01:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id kg6si8062877bkb.144.2013.12.11.01.01.28
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:01:28 -0800 (PST)
Date: Wed, 11 Dec 2013 09:01:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 4/8] sched/numa: fix set cpupid on page migration
 twice against normal page
Message-ID: <20131211090124.GR11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-5-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386723001-25408-5-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 08:49:57AM +0800, Wanpeng Li wrote:
> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over
> the cpupid at page migration time, there is unnecessary to set it again
> in function alloc_misplaced_dst_page, this patch fix it.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

migratepages aops is not necessarily required to go through migrate_page_copy
but in practice all of them do and it's hard to imagine one that didn't
so.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

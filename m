Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id EA9FE6B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:14:25 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so2736486eek.30
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:14:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m49si18085709eeg.199.2013.12.11.01.14.25
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:14:25 -0800 (PST)
Date: Wed, 11 Dec 2013 09:14:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 7/8] sched/numa: fix record hinting faults check
Message-ID: <20131211091422.GU11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-8-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386723001-25408-8-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 08:50:00AM +0800, Wanpeng Li wrote:
> Adjust numa_scan_period in task_numa_placement, depending on how much useful
> work the numa code can do. The local faults and remote faults should be used
> to check if there is record hinting faults instead of local faults and shared
> faults. This patch fix it.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

This potentially has the side-effect of making it easier to reduce the
scan rate because it'll only take the most recent scan window into
account. The existing code takes recent shared accesses into account.
What sort of tests did you do on this patch and what was the result?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

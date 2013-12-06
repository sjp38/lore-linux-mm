Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7A46B006C
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 11:56:49 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id w61so947361wes.0
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 08:56:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l44si15381404eem.250.2013.12.06.08.56.48
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 08:56:48 -0800 (PST)
Date: Fri, 6 Dec 2013 16:56:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 3/6] sched/numa: drop
 sysctl_numa_balancing_settle_count sysctl
Message-ID: <20131206165645.GS11295@suse.de>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386321136-27538-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386321136-27538-3-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 05:12:13PM +0800, Wanpeng Li wrote:
> commit 887c290e (sched/numa: Decide whether to favour task or group weights 
> based on swap candidate relationships) drop the check against 
> sysctl_numa_balancing_settle_count, this patch remove the sysctl.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Doh

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

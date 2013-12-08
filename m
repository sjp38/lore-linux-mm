Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id EAD1D6B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 22:03:17 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so2145313wgh.29
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 19:03:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ba4si2035215wjb.78.2013.12.07.19.03.16
        for <linux-mm@kvack.org>;
        Sat, 07 Dec 2013 19:03:16 -0800 (PST)
Message-ID: <52A3E156.9090700@redhat.com>
Date: Sat, 07 Dec 2013 22:02:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/6] sched/numa: drop sysctl_numa_balancing_settle_count
 sysctl
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386321136-27538-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386321136-27538-3-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/06/2013 04:12 AM, Wanpeng Li wrote:
> commit 887c290e (sched/numa: Decide whether to favour task or group weights 
> based on swap candidate relationships) drop the check against 
> sysctl_numa_balancing_settle_count, this patch remove the sysctl.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

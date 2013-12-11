Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 58EEF6B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:51:02 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2983752eak.30
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:51:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s42si19375845eew.203.2013.12.11.06.50.58
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 06:50:58 -0800 (PST)
Date: Wed, 11 Dec 2013 09:50:28 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386773428-bwklwan0-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131211092123.GV11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-9-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131211092123.GV11295@suse.de>
Subject: Re: [PATCH v5 8/8] sched/numa: drop unnecessary variable in
 task_weight
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 09:21:23AM +0000, Mel Gorman wrote:
> On Wed, Dec 11, 2013 at 08:50:01AM +0800, Wanpeng Li wrote:
> > Drop unnecessary total_faults variable in function task_weight to unify
> > task_weight and group_weight.
> > 
> > Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> 
> Nak.
> 
> task_weight is called for tasks other than current. If p handles a fault
> in parallel then it can drop to 0 between when it's checked and used to
> divide resulting in an oops.

So we have the same race on group_weight(), and we have to add a local
variable to store p->numa_group->total_faults?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

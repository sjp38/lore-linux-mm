Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 62B2B6B0037
	for <linux-mm@kvack.org>; Fri, 20 Sep 2013 08:37:14 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fz6so657732pac.17
        for <linux-mm@kvack.org>; Fri, 20 Sep 2013 05:37:14 -0700 (PDT)
Date: Fri, 20 Sep 2013 14:36:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 46/50] sched: numa: Prevent parallel updates to group
 stats during placement
Message-ID: <20130920123656.GS12926@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-47-git-send-email-mgorman@suse.de>
 <20130920095526.GT9326@twins.programming.kicks-ass.net>
 <20130920123151.GX22421@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130920123151.GX22421@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 20, 2013 at 01:31:52PM +0100, Mel Gorman wrote:
>  static inline unsigned long group_weight(struct task_struct *p, int nid)
>  {
> +	if (!p->numa_group || !p->numa_group->total_faults)
>  		return 0;
>  
> +	return 1200 * group_faults(p, nid) / p->numa_group->total_faults;
>  }

Unrelated to this change; I recently thought we might want to change
these weight factors based on if the task was predominantly private or
shared.

For shared we use the bigger weight for group, for private we use the
bigger weight for task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5AF6B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 13:25:01 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7395413pbc.2
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 10:25:00 -0700 (PDT)
Message-ID: <5252EE60.7030806@redhat.com>
Date: Mon, 07 Oct 2013 13:24:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/63] sched: numa: Continue PTE scanning even if migrate
 rate limited
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-15-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> Avoiding marking PTEs pte_numa because a particular NUMA node is migrate rate
> limited sees like a bad idea. Even if this node can't migrate anymore other
> nodes might and we want up-to-date information to do balance decisions.
> We already rate limit the actual migrations, this should leave enough
> bandwidth to allow the non-migrating scanning. I think its important we
> keep up-to-date information if we're going to do placement based on it.
> 
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

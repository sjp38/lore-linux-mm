Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 290156B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:02:52 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so7536565pdj.31
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:02:51 -0700 (PDT)
Message-ID: <5252F73F.5030809@redhat.com>
Date: Mon, 07 Oct 2013 14:02:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 19/63] sched: Track NUMA hinting faults on per-node basis
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-20-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-20-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> This patch tracks what nodes numa hinting faults were incurred on.
> This information is later used to schedule a task on the node storing
> the pages most frequently faulted by the task.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6624B6B0038
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:07:53 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so7542179pdj.40
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:07:53 -0700 (PDT)
Message-ID: <5253067A.2040607@redhat.com>
Date: Mon, 07 Oct 2013 15:07:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 40/63] sched: numa: Favor placing a task on the preferred
 node
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-41-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-41-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> A tasks preferred node is selected based on the number of faults
> recorded for a node but the actual task_numa_migate() conducts a global
> search regardless of the preferred nid. This patch checks if the
> preferred nid has capacity and if so, searches for a CPU within that
> node. This avoids a global search when the preferred node is not
> overloaded.
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

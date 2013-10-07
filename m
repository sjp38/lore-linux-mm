Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE626B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:40:55 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so7542055pdj.22
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:40:54 -0700 (PDT)
Message-ID: <52530029.7080002@redhat.com>
Date: Mon, 07 Oct 2013 14:40:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 24/63] sched: Reschedule task on preferred NUMA node once
 selected
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-25-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-25-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> A preferred node is selected based on the node the most NUMA hinting
> faults was incurred on. There is no guarantee that the task is running
> on that node at the time so this patch rescheules the task to run on
> the most idle CPU of the selected node when selected. This avoids
> waiting for the balancer to make a decision.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8BBEE6B0039
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:04:14 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so7622511pad.5
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:04:14 -0700 (PDT)
Message-ID: <5252F793.9090200@redhat.com>
Date: Mon, 07 Oct 2013 14:04:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 20/63] sched: Select a preferred node with the most numa
 hinting faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-21-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-21-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> This patch selects a preferred node for a task to run on based on the
> NUMA hinting faults. This information is later used to migrate tasks
> towards the node during balancing.
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

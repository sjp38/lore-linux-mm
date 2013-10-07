Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5536B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:13:17 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so7489229pdj.25
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:13:17 -0700 (PDT)
Message-ID: <525307C1.6060108@redhat.com>
Date: Mon, 07 Oct 2013 15:13:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 51/63] sched: numa: Prevent parallel updates to group
 stats during placement
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-52-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-52-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> Having multiple tasks in a group go through task_numa_placement
> simultaneously can lead to a task picking a wrong node to run on, because
> the group stats may be in the middle of an update. This patch avoids
> parallel updates by holding the numa_group lock during placement
> decisions.
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

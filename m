Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 36ECA6B0039
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:41:39 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so7510724pdj.39
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:41:38 -0700 (PDT)
Message-ID: <52530057.5060105@redhat.com>
Date: Mon, 07 Oct 2013 14:41:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 26/63] sched: Check current->mm before allocating NUMA
 faults
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-27-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-27-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> task_numa_placement checks current->mm but after buffers for faults
> have already been uselessly allocated. Move the check earlier.
> 
> [peterz@infradead.org: Identified the problem]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

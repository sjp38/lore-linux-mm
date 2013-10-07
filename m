Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 869946B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 13:43:10 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so7417739pdj.26
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 10:43:10 -0700 (PDT)
Message-ID: <5252F2A1.4040204@redhat.com>
Date: Mon, 07 Oct 2013 13:42:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/63] Revert "mm: sched: numa: Delay PTE scanning until
 a task is scheduled on a new node"
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-16-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> PTE scanning and NUMA hinting fault handling is expensive so commit
> 5bca2303 ("mm: sched: numa: Delay PTE scanning until a task is scheduled
> on a new node") deferred the PTE scan until a task had been scheduled on
> another node. The problem is that in the purely shared memory case that
> this may never happen and no NUMA hinting fault information will be
> captured. We are not ruling out the possibility that something better
> can be done here but for now, this patch needs to be reverted and depend
> entirely on the scan_delay to avoid punishing short-lived processes.
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

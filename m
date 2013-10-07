Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id A6DF56B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:44:37 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7486313pbc.2
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:44:37 -0700 (PDT)
Message-ID: <52530108.2000505@redhat.com>
Date: Mon, 07 Oct 2013 14:44:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 28/63] sched: Remove check that skips small VMAs
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-29-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-29-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> task_numa_work skips small VMAs. At the time the logic was to reduce the
> scanning overhead which was considerable. It is a dubious hack at best.
> It would make much more sense to cache where faults have been observed
> and only rescan those regions during subsequent PTE scans. Remove this
> hack as motivation to do it properly in the future.
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

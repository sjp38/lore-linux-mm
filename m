Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2D66B003A
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 15:15:34 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so7675360pdj.29
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 12:15:34 -0700 (PDT)
Message-ID: <52530843.4050209@redhat.com>
Date: Mon, 07 Oct 2013 15:15:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 62/63] sched: numa: use unsigned longs for numa group
 fault stats
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-63-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-63-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:29 AM, Mel Gorman wrote:
> As Peter says "If you're going to hold locks you can also do away with all
> that atomic_long_*() nonsense". Lock aquisition moved slightly to protect
> the updates.
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

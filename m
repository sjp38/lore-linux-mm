Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9460F6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 14:02:29 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so7346223pbb.20
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 11:02:29 -0700 (PDT)
Message-ID: <5252F728.4010401@redhat.com>
Date: Mon, 07 Oct 2013 14:02:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 18/63] sched: numa: Slow scan rate if no NUMA hinting
 faults are being recorded
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-19-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> NUMA PTE scanning slows if a NUMA hinting fault was trapped and no page
> was migrated. For long-lived but idle processes there may be no faults
> but the scan rate will be high and just waste CPU. This patch will slow
> the scan rate for processes that are not trapping faults.
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

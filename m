Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7986B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 13:10:40 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7349253pbc.30
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 10:10:40 -0700 (PDT)
Message-ID: <5252EAFF.8040700@redhat.com>
Date: Mon, 07 Oct 2013 13:10:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/63] mm: numa: Do not migrate or account for hinting
 faults on the zero page
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-13-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> The zero page is not replicated between nodes and is often shared between
> processes. The data is read-only and likely to be cached in local CPUs
> if heavily accessed meaning that the remote memory access cost is less
> of a concern. This patch prevents trapping faults on the zero pages. For
> tasks using the zero page this will reduce the number of PTE updates,
> TLB flushes and hinting faults.
> 
> [peterz@infradead.org: Correct use of is_huge_zero_page]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

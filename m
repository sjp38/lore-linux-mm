Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id CA87D6B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 11:12:47 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so7277189pbc.31
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 08:12:47 -0700 (PDT)
Message-ID: <5252CF5A.4000003@redhat.com>
Date: Mon, 07 Oct 2013 11:12:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/63] mm: Do not flush TLB during protection change if
 !pte_present && !migration_entry
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> NUMA PTE scanning is expensive both in terms of the scanning itself and
> the TLB flush if there are any updates. Currently non-present PTEs are
> accounted for as an update and incurring a TLB flush where it is only
> necessary for anonymous migration entries. This patch addresses the
> problem and should reduce TLB flushes.
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

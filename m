Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BD8C46B003C
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 10:02:01 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so7227353pdi.0
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 07:02:01 -0700 (PDT)
Message-ID: <5252BECA.4080302@redhat.com>
Date: Mon, 07 Oct 2013 10:01:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/63] mm: Prevent parallel splits during THP migration
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> THP migrations are serialised by the page lock but on its own that does
> not prevent THP splits. If the page is split during THP migration then
> the pmd_same checks will prevent page table corruption but the unlock page
> and other fix-ups potentially will cause corruption. This patch takes the
> anon_vma lock to prevent parallel splits during migration.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

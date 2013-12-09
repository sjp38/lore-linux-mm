Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB476B00A2
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:31:08 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id b57so1586070eek.31
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:31:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w6si9716586eeg.237.2013.12.09.06.31.04
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:31:05 -0800 (PST)
Message-ID: <52A5D424.7030901@redhat.com>
Date: Mon, 09 Dec 2013 09:31:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/18] mm: numa: Do not clear PTE for pte_numa update
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:08 AM, Mel Gorman wrote:
> The TLB must be flushed if the PTE is updated but change_pte_range is clearing
> the PTE while marking PTEs pte_numa without necessarily flushing the TLB if it
> reinserts the same entry. Without the flush, it's conceivable that two processors
> have different TLBs for the same virtual address and at the very least it would
> generate spurious faults. This patch only unmaps the pages in change_pte_range for
> a full protection change.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

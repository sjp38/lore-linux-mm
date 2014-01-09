Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id A9F656B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 15:12:06 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id u56so953963wes.12
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 12:12:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z12si1964470wjy.72.2014.01.09.12.12.05
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 12:12:05 -0800 (PST)
Message-ID: <52CEFD4F.3080804@redhat.com>
Date: Thu, 09 Jan 2014 14:49:35 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] x86: mm: Eliminate redundant page table walk during
 TLB range flushing
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/09/2014 09:34 AM, Mel Gorman wrote:
> When choosing between doing an address space or ranged flush, the x86
> implementation of flush_tlb_mm_range takes into account whether there are
> any large pages in the range. A per-page flush typically requires fewer
> entries than would covered by a single large page and the check is redundant.
>
> There is one potential exception. THP migration flushes single THP entries
> and it conceivably would benefit from flushing a single entry instead
> of the mm. However, this flush is after a THP allocation, copy and page
> table update potentially with any other threads serialised behind it. In
> comparison to that, the flush is noise. It makes more sense to optimise
> balancing to require fewer flushes than to optimise the flush itself.
>
> This patch deletes the redundant huge page check.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

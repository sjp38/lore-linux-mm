Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id F26A56B0069
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 06:21:02 -0500 (EST)
Date: Thu, 13 Dec 2012 11:20:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3] mm: Use aligned zone start for pfn_to_bitidx
 calculation
Message-ID: <20121213112058.GA9887@suse.de>
References: <1354828301-27849-1-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1354828301-27849-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On Thu, Dec 06, 2012 at 01:11:41PM -0800, Laura Abbott wrote:
> The current calculation in pfn_to_bitidx assumes that
> (pfn - zone->zone_start_pfn) >> pageblock_order will return the
> same bit for all pfn in a pageblock. If zone_start_pfn is not
> aligned to pageblock_nr_pages, this may not always be correct.
> 
> Consider the following with pageblock order = 10, zone start 2MB:
> 
> pfn     | pfn - zone start | (pfn - zone start) >> page block order
> ----------------------------------------------------------------
> 0x26000 | 0x25e00	   |  0x97
> 0x26100 | 0x25f00	   |  0x97
> 0x26200 | 0x26000	   |  0x98
> 0x26300 | 0x26100	   |  0x98
> 
> This means that calling {get,set}_pageblock_migratetype on a single
> page will not set the migratetype for the full block. Fix this by
> rounding down zone_start_pfn when doing the bitidx calculation.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Acked-by: Mel Gorman <mgorman@suse.de>

It's merge window at the moment so it's in danger of getting lost. What
I suggest you do is do is resend to Andrew with the same people cc'd
post-merge window so it'll be picked up in mmotm for the next cycle.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

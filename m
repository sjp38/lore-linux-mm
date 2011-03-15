Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BF1508D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 08:08:15 -0400 (EDT)
Date: Tue, 15 Mar 2011 13:07:48 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
Message-ID: <20110315120748.GE2140@redhat.com>
References: <20110311020410.GH5641@random.random>
 <20110315092750.GD2140@redhat.com>
 <20110315100107.GI10696@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110315100107.GI10696@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

On Tue, Mar 15, 2011 at 11:01:07AM +0100, Andrea Arcangeli wrote:
> Does this look any better? This also optimizes away the tlb flush for
> totally uninitialized areas.

Looks perfect to me, thanks!

> Subject: thp: mremap support and TLB optimization
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This adds THP support to mremap (decreases the number of split_huge_page
> called).
> 
> This also replaces ptep_clear_flush with ptep_get_and_clear and replaces it
> with a final flush_tlb_range to send a single tlb flush IPI instead of one IPI
> for each page.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A41566B005A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 09:50:56 -0400 (EDT)
Date: Thu, 9 Aug 2012 14:50:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] compaction: fix deferring compaction mistake
Message-ID: <20120809135053.GE10288@csn.ul.ie>
References: <1344387464-10037-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1344387464-10037-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed, Aug 08, 2012 at 09:57:44AM +0900, Minchan Kim wrote:
> [1] fixed bad deferring policy but made mistake about checking
> compact_order_failed in __compact_pgdat so it can't update
> compact_order_failed with new order. It ends up preventing working
> of deffering policy rightly. This patch fixes it.
> 
> [1] aff62249, vmscan: only defer compaction for failed order and higher
> 
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

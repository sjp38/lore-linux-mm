Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E6C7E6B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 10:59:43 -0400 (EDT)
Message-ID: <50227E5C.6070903@redhat.com>
Date: Wed, 08 Aug 2012 10:57:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] compaction: fix deferring compaction mistake
References: <1344387464-10037-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1344387464-10037-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On 08/07/2012 08:57 PM, Minchan Kim wrote:
> [1] fixed bad deferring policy but made mistake about checking
> compact_order_failed in __compact_pgdat so it can't update
> compact_order_failed with new order. It ends up preventing working
> of deffering policy rightly. This patch fixes it.

Good catch.

> [1] aff62249, vmscan: only defer compaction for failed order and higher
>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

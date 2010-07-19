Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6D0536B02A9
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 14:43:56 -0400 (EDT)
Message-ID: <4C449CBA.5090703@redhat.com>
Date: Mon, 19 Jul 2010 14:43:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background writeback
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 07/19/2010 09:11 AM, Mel Gorman wrote:
> From: Wu Fengguang<fengguang.wu@intel.com>
>
> A background flush work may run for ever. So it's reasonable for it to
> mimic the kupdate behavior of syncing old/expired inodes first.
>
> This behavior also makes sense from the perspective of page reclaim.
> File pages are added to the inactive list and promoted if referenced
> after one recycling. If not referenced, it's very easy for pages to be
> cleaned from reclaim context which is inefficient in terms of IO. If
> background flush is cleaning pages, it's best it cleans old pages to
> help minimise IO from reclaim.
>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

It can probably be optimized, but we really need something
like this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

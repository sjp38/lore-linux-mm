Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 93B4A6007F5
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:33:29 -0400 (EDT)
Message-ID: <4C445403.3020905@redhat.com>
Date: Mon, 19 Jul 2010 09:32:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] vmscan: tracing: Update post-processing script to
 distinguish between anon and file IO from page reclaim
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-4-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 07/19/2010 09:11 AM, Mel Gorman wrote:
> It is useful to distinguish between IO for anon and file pages. This patch
> updates
> vmscan-tracing-add-a-postprocessing-script-for-reclaim-related-ftrace-events.patch
> so the post-processing script can handle the additional information.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

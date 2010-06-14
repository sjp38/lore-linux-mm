Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E9F726B01D8
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 17:13:53 -0400 (EDT)
Message-ID: <4C169B81.8010707@redhat.com>
Date: Mon, 14 Jun 2010 17:13:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/12] vmscan: Write out dirty pages in batch
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-12-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:
> Page reclaim cleans individual pages using a_ops->writepage() because from
> the VM perspective, it is known that pages in a particular zone must be freed
> soon, it considers the target page to be the oldest and it does not want
> to wait while background flushers cleans other pages. From a filesystem
> perspective this is extremely inefficient as it generates a very seeky
> IO pattern leading to the perverse situation where it can take longer to
> clean all dirty pages than it would have otherwise.

Reclaiming clean pages should be fast enough that this should
make little, if any, difference.

> This patch queues all dirty pages at once to maximise the chances that
> the write requests get merged efficiently. It also makes the next patch
> that avoids writeout from direct reclaim more straight-forward.

However, this is a convincing argument :)

> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

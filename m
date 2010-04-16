Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6FC6B01F0
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 19:34:08 -0400 (EDT)
Date: Sat, 17 Apr 2010 01:34:05 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 10/10] vmscan: Update isolated page counters outside of main path in shrink_inactive_list()
Message-ID: <20100416233405.GK20640@cmpxchg.org>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-11-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271352103-2280-11-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:21:43PM +0100, Mel Gorman wrote:
> When shrink_inactive_list() isolates pages, it updates a number of
> counters using temporary variables to gather them. These consume stack
> and it's in the main path that calls ->writepage(). This patch moves the
> accounting updates outside of the main path to reduce stack usage.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

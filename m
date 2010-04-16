Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB066B01EF
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 18:56:11 -0400 (EDT)
Date: Sat, 17 Apr 2010 00:56:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 04/10] vmscan: Remove useless loop at end of do_try_to_free_pages
Message-ID: <20100416225607.GG20640@cmpxchg.org>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-5-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1271352103-2280-5-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 06:21:37PM +0100, Mel Gorman wrote:
> With the patch "vmscan: kill prev_priority completely", the loop at the
> end of do_try_to_free_pages() is now doing nothing. Delete it.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

Maybe fold that into the prev_priority patch? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

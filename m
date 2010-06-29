Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 32B5E6B01B0
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 10:46:37 -0400 (EDT)
Date: Tue, 29 Jun 2010 16:44:43 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/14] vmscan: Fix mapping use after free
Message-ID: <20100629144443.GD10513@cmpxchg.org>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie> <1277811288-5195-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277811288-5195-2-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 29, 2010 at 12:34:35PM +0100, Mel Gorman wrote:
> From: Nick Piggin <npiggin@suse.de>
> 
> Use lock_page_nosync in handle_write_error as after writepage we have no
> reference to the mapping when taking the page lock.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

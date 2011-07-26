Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 18A7D6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 09:53:48 -0400 (EDT)
Date: Tue, 26 Jul 2011 14:53:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/5] mm: writeback: make determine_dirtyable_memory
 static again
Message-ID: <20110726135343.GC3010@suse.de>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-3-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311625159-13771-3-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2011 at 10:19:16PM +0200, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> The tracing ring-buffer used this function briefly, but not anymore.
> Make it local to the writeback code again.
> 
> Also, move the function so that no forward declaration needs to be
> reintroduced.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

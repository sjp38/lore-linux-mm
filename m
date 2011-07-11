Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CF2536B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 06:05:21 -0400 (EDT)
Date: Mon, 11 Jul 2011 06:05:17 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 13/14] vfs: increase shrinker batch size
Message-ID: <20110711100517.GC19354@infradead.org>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
 <1310098486-6453-14-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1310098486-6453-14-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 08, 2011 at 02:14:45PM +1000, Dave Chinner wrote:
> To allow for a large increase in batch size, add a conditional
> reschedule to prune_icache_sb() so that we don't hold the LRU spin
> lock for too long. This mirrors the behaviour of the
> __shrink_dcache_sb(), and allows us to increase the batch size
> without needing to worry about problems caused by long lock hold
> times.

That doesn't reflect what the patch actually does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

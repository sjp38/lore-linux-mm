Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 072376B007E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 15:21:49 -0400 (EDT)
Date: Mon, 11 Jul 2011 15:21:44 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/14] inode: move to per-sb LRU locks
Message-ID: <20110711192144.GA23723@infradead.org>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
 <1310098486-6453-9-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1310098486-6453-9-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 08, 2011 at 02:14:40PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> With the inode LRUs moving to per-sb structures, there is no longer
> a need for a global inode_lru_lock. The locking can be made more
> fine-grained by moving to a per-sb LRU lock, isolating the LRU
> operations of different filesytsems completely from each other.

Btw, any reason this is not done for dcache_lru_lock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

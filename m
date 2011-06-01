Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 55CEE8D003B
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:39:45 -0400 (EDT)
Date: Tue, 31 May 2011 20:39:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/14] tmpfs: take control of its truncate_range
Message-ID: <20110601003942.GB4433@infradead.org>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
 <alpine.LSU.2.00.1105301737040.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105301737040.5482@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> Note that drivers/gpu/drm/i915/i915_gem.c i915_gem_object_truncate()
> calls the tmpfs ->truncate_range directly: update that in a separate
> patch later, for now just let it duplicate the truncate_inode_pages().
> Because i915 handles unmap_mapping_range() itself at a different stage,
> we have chosen not to bundle that into ->truncate_range.

In your next series that makes it call the readpae replacement directly
it might be nice to also call directly into shmem for hole punching.

> I notice that ext4 is now joining ocfs2 and xfs in supporting fallocate
> FALLOC_FL_PUNCH_HOLE: perhaps they should support truncate_range, and
> tmpfs should support fallocate?  But worry about that another time...

No, truncate_range and the madvice interface are pretty sad hacks that
should never have been added in the first place.  Adding
FALLOC_FL_PUNCH_HOLE support for shmem on the other hand might make
some sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

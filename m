Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 00D346B0255
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 09:02:59 -0400 (EDT)
Date: Fri, 9 Sep 2011 09:02:57 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/10] Avoid dereferencing bd_disk during swap_entry_free
 for network storage
Message-ID: <20110909130257.GA15212@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-11-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315566054-17209-11-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Sep 09, 2011 at 12:00:54PM +0100, Mel Gorman wrote:
> Commit [b3a27d: swap: Add swap slot free callback to
> block_device_operations] dereferences p->bdev->bd_disk but this is a
> NULL dereference if using swap-over-NFS. This patch checks SWP_BLKDEV
> on the swap_info_struct before dereferencing.

Please just remove the callback entirely.  It has no user outside the
staging tree and was added clearly against the rules for that staging
tree.

(and it's butt ugly)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

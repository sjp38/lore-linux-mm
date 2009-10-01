Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A6CF6600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 12:58:58 -0400 (EDT)
Date: Thu, 1 Oct 2009 13:42:01 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/31] Swap over NFS -v20
Message-ID: <20091001174201.GA30068@infradead.org>
References: <1254405858-15651-1-git-send-email-sjayaraman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1254405858-15651-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, Oct 01, 2009 at 07:34:18PM +0530, Suresh Jayaraman wrote:
> Hi,
> 
> Here's the latest version of swap over NFS series since -v19 last October by
> Peter Zijlstra. Peter does not have time to pursue this further (though he has
> not lost interest) and that led me to take over this patchset and try merging
> upstream.
> 
> The patches are against the current mmotm. It does not support SLQB, yet.
> These patches can also be found online here:
> 	http://www.suse.de/~sjayaraman/patches/swap-over-nfs/

My advise again that I already gave to Peter long ago.  It's almost
impossible to get a patchset that large and touching many subsystems in.

Split it into smaller series that make sense of their own.  One of them
would be the whole VM/net work to just make swap over nbd/iscsi safe.

The other really big one is adding a proper method for safe, page-backed
kernelspace I/O on files.  That is not something like the grotty
swap-tied address_space operations in this patch, but more something in
the direction of the kernel direct I/O patches from Jenx Axboe he did
for using in the loop driver.  But even those aren't complete as they
don't touch the locking issue yet.

Especially the latter is an absolutely essential step to make any
progress here, and an excellent patch series of it's own as there are
multiple users for this, like making swap safe on btrfs files, making
the MD bitmap code actually safe or improving the loop driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

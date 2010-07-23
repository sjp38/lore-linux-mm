Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 87CA96B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 07:17:52 -0400 (EDT)
Date: Fri, 23 Jul 2010 07:17:46 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: VFS scalability git tree
Message-ID: <20100723111746.GA5169@infradead.org>
References: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722190100.GA22269@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I might sound like a broken record, but if you want to make forward
progress with this split it into smaller series.

What would be useful for example would be one series each to split
the global inode_lock and dcache_lock, without introducing all the
fancy new locking primitives, per-bucket locks and lru schemes for
a start.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

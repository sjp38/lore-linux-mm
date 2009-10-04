Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF8C6B004D
	for <linux-mm@kvack.org>; Sun,  4 Oct 2009 17:41:20 -0400 (EDT)
Subject: Re: [PATCH 00/31] Swap over NFS -v20
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20091001174201.GA30068@infradead.org>
References: <1254405858-15651-1-git-send-email-sjayaraman@suse.de>
	 <20091001174201.GA30068@infradead.org>
Content-Type: text/plain
Date: Sun, 04 Oct 2009 23:41:22 +0200
Message-Id: <1254692482.21044.15.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thu, 2009-10-01 at 13:42 -0400, Christoph Hellwig wrote:
> One of them
> would be the whole VM/net work to just make swap over nbd/iscsi safe.

Getting those two 'fixed' is going to be tons of interesting work
because they involve interaction with userspace daemons.

NBD has fairly simple userspace, but iSCSI has a rather large userspace
footprint and a rather complicated user/kernel interaction which will be
mighty interesting to get allocation safe.

Ideally the swap-over-$foo bits have no userspace component.

That said, Wouter is the NBD userspace maintainer and has expressed
interest into looking at making that work, but its sure going to be
non-trivial, esp. since exposing PF_MEMALLOC to userspace is a, not over
my dead-bodym like thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

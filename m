Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 392D16B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:42:25 -0400 (EDT)
Date: Sat, 24 Jul 2010 01:42:20 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100723154220.GA5773@amd>
References: <20100722190100.GA22269@amd>
 <20100723111746.GA5169@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723111746.GA5169@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 07:17:46AM -0400, Christoph Hellwig wrote:
> I might sound like a broken record, but if you want to make forward
> progress with this split it into smaller series.

No I appreciate the advice. I put this tree up for people to fetch
without posting patches all the time. I think it is important to
test and to see the big picture when reviewing the patches, but you
are right about how to actually submit patches on the ML.


> What would be useful for example would be one series each to split
> the global inode_lock and dcache_lock, without introducing all the
> fancy new locking primitives, per-bucket locks and lru schemes for
> a start.

I've kept the series fairly well structured like that. Basically it
is in these parts:

1. files lock
2. vfsmount lock
3. mnt refcount
4a. put several new global spinlocks around different parts of dcache
4b. remove dcache_lock after the above protect everything
4c. start doing fine grained locking of hash, inode alias, lru, etc etc
5a, 5b, 5c. same for inodes
6. some further optimisations and cleanups
7. store-free path walking

This kind of sequence. I will again try to submit a first couple of
things to Al soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

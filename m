Message-ID: <3D7563C0.99EE8843@zip.com.au>
Date: Tue, 03 Sep 2002 18:37:04 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm1
References: <3D7437AC.74EAE22B@zip.com.au> <20020904004028.GS888@holomorphy.com> <3D755E2D.7A6D55C6@zip.com.au> <20020904011503.GT888@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> ...
> > Calling kmem_cache_reap() after running the pruners will fix that up.
> 
> # grep ext3_inode_cache /proc/slabinfo
> ext3_inode_cache   18917  87012    448 7686 9668    1
> ...
> ext3_inode_cache:     8098KB    38052KB   21.28
> 
> Looks like a persistent gap from here.

OK, thanks.  We need to reap those pages up-front rather than waiting
for them to come to the tail of the LRU.

What on earth is going on with kmem_cache_reap?  Am I missing
something, or is that thing 700% overdesigned?  Why not just
free the darn pages in kmem_cache_free_one()?  Maybe hang onto
a few pages for cache warmth, but heck.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

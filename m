Date: Wed, 29 Jun 2005 19:49:59 +0900 (JST)
Message-Id: <20050629.194959.98866345.taka@valinux.co.jp>
Subject: Re: [rfc] lockless pagecache
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <42BF9CD1.2030102@yahoo.com.au>
References: <42BF9CD1.2030102@yahoo.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

Your patches improve the performance if lots of processes are
accessing the same file at the same time, right?

If so, I think we can introduce multiple radix-trees instead,
which enhance each inode to be able to have two or more radix-trees
in it to avoid the race condition traversing the trees.
Some decision mechanism is needed which radix-tree each page
should be in, how many radix-tree should be prepared.

It seems to be simple and effective.

What do you think?

> Now the tree_lock was recently(ish) converted to an rwlock, precisely
> for such a workload and that was apparently very successful. However
> an rwlock is significantly heavier, and as machines get faster and
> bigger, rwlocks (and any locks) will tend to use more and more of Paul
> McKenney's toilet paper due to cacheline bouncing.
> 
> So in the interest of saving some trees, let's try it without any locks.
> 
> First I'll put up some numbers to get you interested - of a 64-way Altix
> with 64 processes each read-faulting in their own 512MB part of a 32GB
> file that is preloaded in pagecache (with the proper NUMA memory
> allocation).

Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

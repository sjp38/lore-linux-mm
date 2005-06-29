Message-ID: <42C28846.60702@yahoo.com.au>
Date: Wed, 29 Jun 2005 21:38:46 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] lockless pagecache
References: <42BF9CD1.2030102@yahoo.com.au> <20050629.194959.98866345.taka@valinux.co.jp>
In-Reply-To: <20050629.194959.98866345.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hirokazu Takahashi wrote:
> Hi Nick,
> 

Hi,

> Your patches improve the performance if lots of processes are
> accessing the same file at the same time, right?
> 

Yes.

> If so, I think we can introduce multiple radix-trees instead,
> which enhance each inode to be able to have two or more radix-trees
> in it to avoid the race condition traversing the trees.
> Some decision mechanism is needed which radix-tree each page
> should be in, how many radix-tree should be prepared.
> 
> It seems to be simple and effective.
> 
> What do you think?
> 

Sure it is a possibility.

I don't think you could call it effective like a completely
lockless version is effective. You might take more locks during
gang lookups, you may have a lot of ugly and not-always-working
heuristics (hey, my app goes really fast if it spreads accesses
over a 1GB file, but falls on its face with a 10MB one). You
might get increased cache footprints for common operations.

I mainly did the patches for a bit of fun rather than to address
a particular problem with a real workload and as such I won't be
pushing to get them in the kernel for the time being.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

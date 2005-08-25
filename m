Message-ID: <430D1C03.4000200@yahoo.com.au>
Date: Thu, 25 Aug 2005 11:16:51 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [fucillo@intersystems.com: process creation time increases linearly
 with shmem]
References: <20050824181409.GC6932@linux.intel.com>
In-Reply-To: <20050824181409.GC6932@linux.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

FYI, see my reply on lkml too (it might start a thread of its own).

I recently had a quick look into why this is so when I heard some
other operating systems do better than us here.

I believe it is because we copy all page tables though we need not
copy those that are filebacked MAP_SHARED. The patch to change this
is fairly trivial, though I didn't have a real world test to justify
any improvement.

Actually, it may be worthwhile for another reason on large NUMA
systems so their leaf page tables get allocated on the same node
in which the memory is used.

Benjamin LaHaise wrote:
> ----- Forwarded message from Ray Fucillo <fucillo@intersystems.com> -----
> 
> Subject: process creation time increases linearly with shmem
> From: Ray Fucillo <fucillo@intersystems.com>
> To: linux-kernel@vger.kernel.org
> Date: 	Wed, 24 Aug 2005 14:43:29 -0400
> Resent-Message-Id: <200508241914.j7OJE7wm027367@orsfmr002.jf.intel.com>
> Resent-Sender: Benjamin LaHaise <bcrl@kvack.org>
> Resent-From: bcrl@kvack.org
> Resent-Date: Wed, 24 Aug 2005 15:13:51 -0400
> Resent-To: bcrl@linux.intel.com
> 
> I am seeing process creation time increase linearly with the size of the 
> shared memory segment that the parent touches.  The attached forktest.c 
> is a very simple user program that illustrates this behavior, which I 
> have tested on various kernel versions from 2.4 through 2.6.  Is this a 
> known issue, and is it solvable?

[snip]

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

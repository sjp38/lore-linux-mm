Date: Sun, 23 Mar 2003 19:17:44 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.65-mm4
Message-Id: <20030323191744.56537860.akpm@digeo.com>
In-Reply-To: <9590000.1048475057@[10.10.2.4]>
References: <20030323020646.0dfcc17b.akpm@digeo.com>
	<9590000.1048475057@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> profile from SDET 64:

SDET is rather irritating because a) nobody has a copy and b) we don't even
know what it does.

> 
> 82303 __down
> 42835 schedule
> 31323 __wake_up
> 26435 .text.lock.sched
> 15924 .text.lock.transaction

But judging by this, it's a rebadged dbench.  The profile is identical.

Note that the lock_kernel() contention has been drastically reduced and we're
now hitting semaphore contention.

Running `dbench 32' on the quad Xeon, this patch took the context switch rate
from 500/sec up to 125,000/sec.

I've asked Alex to put together a patch for spinlock-based locking in the
block allocator (cut-n-paste from ext2).

That will fix up lock_super(), but I suspect the main problem is the
lock_journal() in journal_start().  I haven't thought about that one yet.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

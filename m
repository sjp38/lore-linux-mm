Date: Sun, 23 Mar 2003 20:10:05 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.65-mm4
Message-ID: <11750000.1048479004@[10.10.2.4]>
In-Reply-To: <20030323191744.56537860.akpm@digeo.com>
References: <20030323020646.0dfcc17b.akpm@digeo.com>
 <9590000.1048475057@[10.10.2.4]> <20030323191744.56537860.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> profile from SDET 64:
> 
> SDET is rather irritating because a) nobody has a copy and b) we don't
> even know what it does.

Yeah, I know. sorry ... I'm trying to get aim7 done instead.

> and b) we don't even know what it does.

Lots of shell scripty stuff, I think.

>> 82303 __down
>> 42835 schedule
>> 31323 __wake_up
>> 26435 .text.lock.sched
>> 15924 .text.lock.transaction
> 
> But judging by this, it's a rebadged dbench.  The profile is identical.

Not sure what dbench does. But I'm probably doing lots of small reads
and writes inside pagecache.
 
> Note that the lock_kernel() contention has been drastically reduced and
> we're now hitting semaphore contention.
> 
> Running `dbench 32' on the quad Xeon, this patch took the context switch
> rate from 500/sec up to 125,000/sec.
> 
> I've asked Alex to put together a patch for spinlock-based locking in the
> block allocator (cut-n-paste from ext2).

OK, sounds like a plan. Made a huge impact for ext2, and might enable
us to actually be able to see the rest of it through the sem cloud.
 
> That will fix up lock_super(), but I suspect the main problem is the
> lock_journal() in journal_start().  I haven't thought about that one yet.

Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

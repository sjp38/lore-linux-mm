Message-ID: <46156CA9.3060105@redhat.com>
Date: Thu, 05 Apr 2007 17:39:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<461357C4.4010403@yahoo.com.au>	<46154226.6080300@redhat.com> <20070405140723.8477e314.akpm@linux-foundation.org>
In-Reply-To: <20070405140723.8477e314.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ulrich Drepper <drepper@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS

> I wonder which way you're using, and whether using the other way changes
> things.

I'm using the default Fedora config file, which has
NR_CPUS defined to 64 and CONFIG_SPLIT_PTLOCK_CPUS
to 4, so I am using the split locks.

However, I suspect that each 512kB malloced area
will share one page table lock with 4 others, so
some contention is to be expected.

>> For more real world workloads, like the MySQL sysbench one,
>> I still suspect that your patch would improve things.
>>
>> Time to move back to debugging other stuff, though.
>>
>> Andrew, it would be nice if our patches could cook in -mm
>> for a while.  Want me to change anything before submitting?
> 
> umm.  I took a quick squint at a patch from you this morning and it looked
> OK to me.  Please send the finalish thing when it is fully baked and
> performance-tested in the various regions of operation, thanks.

Will do.

Ulrich has a test version of glibc available that
uses MADV_DONTNEED for free(3), that should test
this thing nicely.

I'll run some tests with that when I get the
time, hopefully next week.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <46151A05.3050505@redhat.com>
Date: Thu, 05 Apr 2007 11:47:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com>	<4614A5CC.5080508@redhat.com>	<4614A7B1.60808@redhat.com> <20070405013225.4135b76d.akpm@linux-foundation.org>
In-Reply-To: <20070405013225.4135b76d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 05 Apr 2007 03:39:29 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
>> Rik van Riel wrote:
>>
>>> MADV_DONTNEED, unpatched, 1000 loops
>>>
>>> real    0m13.672s
>>> user    0m1.217s
>>> sys     0m45.712s
>>>
>>>
>>> MADV_DONTNEED, with patch, 1000 loops
>>>
>>> real    0m4.169s
>>> user    0m2.033s
>>> sys     0m3.224s
>> I just noticed something fun with these numbers.
>>
>> Without the patch, the system (a quad core CPU) is 10% idle.
>>
>> With the patch, it is 66% idle - presumably I need Nick's
>> mmap_sem patch.
>>
>> However, despite being 66% idle, the test still runs over
>> 3 times as fast!
> 
> Please quote the context switch rate when testing this stuff (I use vmstat 1).
> I've seen it vary by a factor of 10,000 depending upon what's happening.

About context switches 14000 per second.

I'll go compile in Nick's patch to see if that makes
things go faster.  I expect it will.

procs -----------memory---------- ---swap-- -----io---- --system-- 
-----cpu------
  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy 
id wa st
  1  0      0 965232 250024 370848    0    0     0     0 1026 13914 13 
21 67  0  0
  1  0      0 965232 250024 370848    0    0     0     0 1018 14654 12 
20 68  0  0
  1  0      0 965232 250024 370848    0    0     0     0 1023 14006 12 
21 67  0  0


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

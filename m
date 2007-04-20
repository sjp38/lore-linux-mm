Message-ID: <4629524C.5040302@redhat.com>
Date: Fri, 20 Apr 2007 19:52:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org>
In-Reply-To: <20070420150618.179d31a4.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 20 Apr 2007 17:38:06 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
>> Andrew Morton wrote:
>>
>>> I've also merged Nick's "mm: madvise avoid exclusive mmap_sem".
>>>
>>> - Nick's patch also will help this problem.  It could be that your patch
>>>   no longer offers a 2x speedup when combined with Nick's patch.
>>>
>>>   It could well be that the combination of the two is even better, but it
>>>   would be nice to firm that up a bit.  
>> I'll test that.
> 
> Thanks.

Well, good news.

It turns out that Nick's patch does not improve peak
performance much, but it does prevent the decline when
running with 16 threads on my quad core CPU!

We _definately_ want both patches, there's a huge benefit
in having them both.

Here are the transactions/seconds for each combination:

    vanilla   new glibc  madv_free kernel   madv_free + mmap_sem
threads

1     610         609             596                545
2    1032        1136            1196               1200
4    1070        1128            2014               2024
8    1000        1088            1665               2087
16    779        1073            1310               1999


-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

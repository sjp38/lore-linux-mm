Message-ID: <462C2F33.8090508@redhat.com>
Date: Sun, 22 Apr 2007 23:59:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com>
In-Reply-To: <462C2DC7.5070709@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
>> Rik van Riel wrote:
>>> Nick Piggin wrote:
>>>
>>>> Rik van Riel wrote:
>>
>>>>> Here are the transactions/seconds for each combination:
> 
> I've added a 5th column, with just your mmap_sem patch and
> without my madv_free patch.  It is run with the glibc patch,
> which should make it fall back to MADV_DONTNEED after the
> first MADV_FREE call fails.
> 
>>>>>    vanilla   new glibc  madv_free kernel   madv_free + mmap_sem  
>>>>> mmap_sem
>>>>> threads
>>>>>
>>>>> 1     610         609             596                545         534
>>>>> 2    1032        1136            1196               1200        1180
>>>>> 4    1070        1128            2014               2024        2027
>>>>> 8    1000        1088            1665               2087        2089
>>>>> 16    779        1073            1310               1999        2012

Now that I think about it - this is all with the rawhide kernel
configuration, which has an ungodly number of debug config
options enabled.

I should try this with a more normal kernel, on various different
systems.

It would also be helpful if other people tried this same benchmark,
and others, on their systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

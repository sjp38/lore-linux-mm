Message-ID: <462C37B9.5090600@yahoo.com.au>
Date: Mon, 23 Apr 2007 14:36:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com> <20070420135715.f6e8e091.akpm@linux-foundation.org> <462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <20070421071202.GA355@devserv.devel.redhat.com>
In-Reply-To: <20070421071202.GA355@devserv.devel.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakub Jelinek <jakub@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>
List-ID: <linux-mm.kvack.org>

Jakub Jelinek wrote:
> On Fri, Apr 20, 2007 at 07:52:44PM -0400, Rik van Riel wrote:
> 
>>It turns out that Nick's patch does not improve peak
>>performance much, but it does prevent the decline when
>>running with 16 threads on my quad core CPU!
>>
>>We _definately_ want both patches, there's a huge benefit
>>in having them both.
>>
>>Here are the transactions/seconds for each combination:
>>
>>   vanilla   new glibc  madv_free kernel   madv_free + mmap_sem
>>threads
>>
>>1     610         609             596                545
>>2    1032        1136            1196               1200
>>4    1070        1128            2014               2024
>>8    1000        1088            1665               2087
>>16    779        1073            1310               1999
> 
> 
> FYI, I have uploaded a testing glibc that uses MADV_FREE and falls back
> to MADV_DONTUSE if MADV_FREE is not available, to
> http://people.redhat.com/jakub/glibc/2.5.90-21.1/

Hmm, I wonder how glibc malloc stacks up to tcmalloc on this test
(after the mmap_sem patch as well).

I'll try running that as well!

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

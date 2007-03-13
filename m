Message-ID: <45F6967F.4020002@yahoo.com.au>
Date: Tue, 13 Mar 2007 23:18:07 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
References: <20070313071325.4920.82870.sendpatchset@schroedinger.engr.sgi.com>	<20070313005334.853559ca.akpm@linux-foundation.org>	<45F65ADA.9010501@yahoo.com.au>	<20070313035250.f908a50e.akpm@linux-foundation.org>	<45F685C6.8070806@yahoo.com.au>	<20070313041551.565891b5.akpm@linux-foundation.org>	<45F68B4B.9020200@yahoo.com.au>	<20070313044756.b45649ac.akpm@linux-foundation.org>	<45F69287.8040509@yahoo.com.au> <20070313051109.3215104b.akpm@linux-foundation.org>
In-Reply-To: <20070313051109.3215104b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>>On Tue, 13 Mar 2007 23:01:11 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>Andrew Morton wrote:

>>>It would be interesting to look at a) leave the page full of random garbage
>>>if we're releasing the whole mm and b) return it straight to the page allocator.
>>
>>Well we have the 'fullmm' case, which avoids all the locked pte operations
>>(for those architectures where hardware pt walking requires atomicity).
> 
> 
> I suspect there are some tlb operations which could be skipped in that case
> too.

Depends on the tlb flush implementation. The generic one doesn't look like
it is all that smart about optimising the fullmm case. It does skip some
tlb flushing though.

>>However we still have to visit those to-be-unmapped parts of the page table
>>to find the pages and free them. So we still at least need to bring it into
>>cache for the read... at which point, the store probably isn't a big burden.
> 
> 
> It means all that data has to be written back.  Yes, I expect it'll prove
> to be less costly than the initial load.

Still, it is something we could try.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

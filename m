Message-ID: <45F69287.8040509@yahoo.com.au>
Date: Tue, 13 Mar 2007 23:01:11 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [QUICKLIST 0/4] Arch independent quicklists V2
References: <20070313071325.4920.82870.sendpatchset@schroedinger.engr.sgi.com>	<20070313005334.853559ca.akpm@linux-foundation.org>	<45F65ADA.9010501@yahoo.com.au>	<20070313035250.f908a50e.akpm@linux-foundation.org>	<45F685C6.8070806@yahoo.com.au>	<20070313041551.565891b5.akpm@linux-foundation.org>	<45F68B4B.9020200@yahoo.com.au> <20070313044756.b45649ac.akpm@linux-foundation.org>
In-Reply-To: <20070313044756.b45649ac.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>>On Tue, 13 Mar 2007 22:30:19 +1100 Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>We don't actually have to zap_pte_range the entire page table in
>>order to free it (IIRC we used to have to, before the 4lpt patches).
> 
> 
> I'm trying to remember why we ever would have needed to zero out the pagetable
> pages if we're taking down the whole mm?  Maybe it's because "oh, the
> arch wants to put this page into a quicklist to recycle it", which is
> all rather circular.
> 
> It would be interesting to look at a) leave the page full of random garbage
> if we're releasing the whole mm and b) return it straight to the page allocator.

Well we have the 'fullmm' case, which avoids all the locked pte operations
(for those architectures where hardware pt walking requires atomicity).

However we still have to visit those to-be-unmapped parts of the page table,
to find the pages and free them. So we still at least need to bring it into
cache for the read... at which point, the store probably isn't a big burden.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

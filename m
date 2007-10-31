Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9VBOc35012246
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 07:24:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VBOcnM491920
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 07:24:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VBObSN030737
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 07:24:37 -0400
Message-ID: <472865E8.4070908@linux.vnet.ibm.com>
Date: Wed, 31 Oct 2007 16:54:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Swap delay accounting, include lock_page() delays
References: <20071031075243.22225.53636.sendpatchset@balbir-laptop> <200710311841.53671.nickpiggin@yahoo.com.au> <200710312010.33833.nickpiggin@yahoo.com.au>
In-Reply-To: <200710312010.33833.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM Mailing List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Wednesday 31 October 2007 18:41, Nick Piggin wrote:
>> On Wednesday 31 October 2007 18:52, Balbir Singh wrote:
>>> Reported-by: Nick Piggin <nickpiggin@yahoo.com.au>
>>>
>>> The delay incurred in lock_page() should also be accounted in swap delay
>>> accounting
>>>
>>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Ah right, I forgot to resend this one, sorry. Thanks for remembering.
> 
> Although, I think I had a bit more detail in the changelog which
> I think should be kept.
> 
> Basically, swap delay accounting seems quite broken as of now,
> because what it is counting is the time required to allocate a new
> page and submit the IO, but not actually the time to perform the IO
> at all (which I'd expect will be significant, although possibly in
> some workloads the actual page allocation will dominate).
> 

This looks quite good to me. I'm off attending a wedding, I'll resend
the patch when I am back.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

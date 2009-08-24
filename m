Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 73F6A6B005C
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 21:12:08 -0400 (EDT)
Received: by pxi15 with SMTP id 15so6420576pxi.23
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:12:06 -0700 (PDT)
Message-ID: <4A930313.9070404@vflare.org>
Date: Tue, 25 Aug 2009 02:46:03 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com> <4A92EBB4.1070101@vflare.org> <Pine.LNX.4.64.0908242132320.8144@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908242132320.8144@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/25/2009 02:09 AM, Hugh Dickins wrote:
> On Tue, 25 Aug 2009, Nitin Gupta wrote:
>> On 08/24/2009 11:03 PM, Pekka Enberg wrote:
>>>
>>> What's the purpose of passing PFNs around? There's quite a lot of PFN
>>> to struct page conversion going on because of it. Wouldn't it make
>>> more sense to return (and pass) a pointer to struct page instead?
>>
>> PFNs are 32-bit on all archs
>
> Are you sure?  If it happens to be so for all machines built today,
> I think it can easily change tomorrow.  We consistently use unsigned long
> for pfn (there, now I've said that, I bet you'll find somewhere we don't!)
>
> x86_64 says MAX_PHYSMEM_BITS 46 and ia64 says MAX_PHYSMEM_BITS 50 and
> mm/sparse.c says
> unsigned long max_sparsemem_pfn = 1UL<<  (MAX_PHYSMEM_BITS-PAGE_SHIFT);
>

For PFN to exceed 32-bit we need to have physical memory > 16TB (2^32 * 4KB).
So, maybe I can simply add a check in ramzswap module load to make sure that
RAM is indeed < 16TB and then safely use 32-bit for PFN?

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

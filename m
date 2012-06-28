Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 4B4D96B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 22:05:22 -0400 (EDT)
Message-ID: <4FEBBB5C.5000505@intel.com>
Date: Thu, 28 Jun 2012 10:03:08 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com> <4FEAA7A1.9020307@kernel.org> <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default> <4FEB5204.3090707@linux.vnet.ibm.com>
In-Reply-To: <4FEB5204.3090707@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, "H. Peter Anvin" <hpa@zytor.com>

On 06/28/2012 02:33 AM, Seth Jennings wrote:

> On 06/27/2012 10:12 AM, Dan Magenheimer wrote:
>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>> Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
>>>
>>> On 06/27/2012 03:14 PM, Alex Shi wrote:
>>>>
>>>> On 06/27/2012 01:53 PM, Minchan Kim wrote:
>>>> Different CPU type has different balance point on the invlpg replacing
>>>> flush all. and some CPU never get benefit from invlpg, So, it's better
>>>> to use different value for different CPU, not a fixed
>>>> INVLPG_BREAK_EVEN_PAGES.
>>>
>>> I think it could be another patch as further step and someone who are
>>> very familiar with architecture could do better than.
>>> So I hope it could be merged if it doesn't have real big problem.
>>>
>>> Thanks for the comment, Alex.
>>
>> Just my opinion, but I have to agree with Alex.  Hardcoding
>> behavior that is VERY processor-specific is a bad idea.  TLBs should
>> only be messed with when absolutely necessary, not for the
>> convenience of defending an abstraction that is nice-to-have
>> but, in current OS kernel code, unnecessary.
> 
> I agree that it's not optimal.  The selection based on CPUID
> is part of Alex's patchset, and I'll be glad to use that
> code when it gets integrated.
> 
> But the real discussion is are we going to:
> 1) wait until Alex's patches to be integrated, degrading
> zsmalloc in the meantime or


Peter Anvin is merging my TLB patch set into tip tree, x86/mm branch.

> 2) put in some simple temporary logic that works well (not
> best) for most cases


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

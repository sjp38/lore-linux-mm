Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D88BB6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:36:31 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 27 Jun 2012 14:36:27 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F1F6638C81F0
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:35:37 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5RIZad136503736
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 14:35:36 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5S06QB7022644
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:06:28 -0400
Message-ID: <4FEB5267.8000109@linux.vnet.ibm.com>
Date: Wed, 27 Jun 2012 13:35:19 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
References: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com> <1340640878-27536-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FEA9FDD.6030102@kernel.org> <4FEAA4AA.3000406@intel.com> <4FEAA7A1.9020307@kernel.org> <90bcc2c8-bcac-4620-b3c0-6b65f8d9174d@default> <20120627153911.GH17154@phenom.dumpdata.com>
In-Reply-To: <20120627153911.GH17154@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Minchan Kim <minchan@kernel.org>, Alex Shi <alex.shi@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On 06/27/2012 10:39 AM, Konrad Rzeszutek Wilk wrote:
> On Wed, Jun 27, 2012 at 08:12:56AM -0700, Dan Magenheimer wrote:
>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>> Subject: Re: [PATCH 3/3] x86: add local_tlb_flush_kernel_range()
>>>
>>> Hello,
>>>
>>> On 06/27/2012 03:14 PM, Alex Shi wrote:
>>>
>>>> On 06/27/2012 01:53 PM, Minchan Kim wrote:
>>>>
>>>>> On 06/26/2012 01:14 AM, Seth Jennings wrote:
>>>>>
>>>>>> This patch adds support for a local_tlb_flush_kernel_range()
>>>>>> function for the x86 arch.  This function allows for CPU-local
>>>>>> TLB flushing, potentially using invlpg for single entry flushing,
>>>>>> using an arch independent function name.
>>>>>>
>>>>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>>>>
>>>>>
>>>>> Anyway, we don't matter INVLPG_BREAK_EVEN_PAGES's optimization point is 8 or something.
>>>>
>>>>
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
> At least put a big fat comment in the patch saying:
> "This is based on research done by Alex, where ...

I can do this.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

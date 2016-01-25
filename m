Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C78CC828DF
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:07:12 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n5so71202446wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:07:12 -0800 (PST)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id e18si27461367wjn.112.2016.01.25.02.07.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 02:07:11 -0800 (PST)
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 25 Jan 2016 10:07:11 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 944CA17D806B
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:07:13 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0PA75P6590200
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:07:05 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0PA75KC032246
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:07:05 -0500
Subject: Re: [PATCH] mm/debug_pagealloc: Ask users for default setting of
 debug_pagealloc
References: <1453713588-119602-1-git-send-email-borntraeger@de.ibm.com>
 <20160125094132.GA4298@osiris> <56A5EECE.90607@de.ibm.com>
 <20160125100248.GB4298@osiris>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A5F3C8.4050202@de.ibm.com>
Date: Mon, 25 Jan 2016 11:07:04 +0100
MIME-Version: 1.0
In-Reply-To: <20160125100248.GB4298@osiris>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/25/2016 11:02 AM, Heiko Carstens wrote:
> On Mon, Jan 25, 2016 at 10:45:50AM +0100, Christian Borntraeger wrote:
>>>> +	  By default this option will be almost for free and can be activated
>>>> +	  in distribution kernels. The overhead and the debugging can be enabled
>>>> +	  by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc command line
>>>> +	  parameter.
>>>
>>> Sorry, but it's not almost for free and should not be used by distribution
>>> kernels. If we have DEBUG_PAGEALLOC enabled, at least on s390 we will not
>>> make use of 2GB and 1MB pagetable entries for the identy mapping anymore.
>>> Instead we will only use 4K mappings.
>>
>> Hmmm, can we change these code areas to use debug_pagealloc_enabled? I guess
>> this evaluated too late?
> 
> Yes, that should be possible. "debug_pagealloc" is an early_param, which
> will be evaluated before we call paging_init() (both in
> arch/s390/kernel/setup.c).
> 
> So it looks like this can be trivially changed. (replace the ifdefs in
> arch/s390/mm/vmem.c with debug_pagealloc_enabled()).
> 
>>> I assume this is true for all architectures since freeing pages can happen
>>> in any context and therefore we can't allocate memory in order to split
>>> page tables.
>>>
>>> So enabling this will cost memory and put more pressure on the TLB.
>>
>> So I will change the description and drop the "if unsure" statement.
> 
> Well, given that we can change it like above... I don't care anymore ;)

Ok, I will give it a try, and come back with a rewording or an s390 patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

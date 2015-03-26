Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 564E96B006E
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:08:05 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so16016952pac.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 09:08:05 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id nb4si8921348pbc.184.2015.03.26.09.08.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 26 Mar 2015 09:08:04 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLT00C4JUC3RQ30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Mar 2015 16:12:03 +0000 (GMT)
Message-id: <55142EDA.4020301@samsung.com>
Date: Thu, 26 Mar 2015 19:07:54 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
 <20150325145523.94d1033b93cd5c1010df93bf@linux-foundation.org>
In-reply-to: <20150325145523.94d1033b93cd5c1010df93bf@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

On 03/26/2015 12:55 AM, Andrew Morton wrote:
> On Tue, 24 Mar 2015 16:10:01 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
>> Elements backed by the slab allocator are poisoned when added to a
>> mempool's reserved pool.
>>
>> It is also possible to poison elements backed by the page allocator
>> because the mempool layer knows the allocation order.
>>
>> This patch extends mempool element poisoning to include memory backed by
>> the page allocator.
>>
>> This is only effective for configs with CONFIG_DEBUG_SLAB or
>> CONFIG_SLUB_DEBUG_ON.
>>
> 
> Maybe mempools should get KASAN treatment (as well as this)?
> 

Certainly, I could cook a patch tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

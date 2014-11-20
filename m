Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5666B0069
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 03:47:41 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so2123497pac.25
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 00:47:40 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id dw1si2152670pab.181.2014.11.20.00.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 20 Nov 2014 00:47:39 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFB00CC3XVX0490@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 20 Nov 2014 08:50:21 +0000 (GMT)
Message-id: <546DAA99.5070402@samsung.com>
Date: Thu, 20 Nov 2014 11:47:21 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
References: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On 11/20/2014 02:46 AM, David Rientjes wrote:
> On Mon, 10 Nov 2014, Andrey Ryabinin wrote:
> 
>> kmem_cache_zalloc_node() allocates zeroed memory for a particular
>> cache from a specified memory node. To be used for struct irq_desc.
>>
> 
> Is there a reason to add this for such a specialized purpose to the slab 
> allocator?  I think it can just be handled for struct irq_desc explicitly.
> 

It could be used not only for irq_desc. Grepping sources gave me 7 possible users.

We already have zeroing variants of kmalloc/kmalloc_node/kmem_cache_alloc,
so why kmem_cache_alloc_node is special?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

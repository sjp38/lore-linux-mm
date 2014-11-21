Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 46B306B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:30:03 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id z10so4643694pdj.12
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:30:02 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id wn6si6144428pac.222.2014.11.20.22.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 20 Nov 2014 22:30:02 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NFD0010GM6P4P40@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 21 Nov 2014 06:32:49 +0000 (GMT)
Message-id: <546EDBE0.10103@samsung.com>
Date: Fri, 21 Nov 2014 09:29:52 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
References: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.10.1411191545210.32057@chino.kir.corp.google.com>
 <546DAA99.5070402@samsung.com>
 <alpine.DEB.2.10.1411201430220.30354@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1411201430220.30354@chino.kir.corp.google.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On 11/21/2014 01:31 AM, David Rientjes wrote:
> On Thu, 20 Nov 2014, Andrey Ryabinin wrote:
> 
>>> Is there a reason to add this for such a specialized purpose to the slab 
>>> allocator?  I think it can just be handled for struct irq_desc explicitly.
>>>
>>
>> It could be used not only for irq_desc. Grepping sources gave me 7 possible users.
>>
> 
> It would be best to follow in the example of those users and just use 
> __GFP_ZERO.
> 

Fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

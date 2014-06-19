Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 19F1B6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 03:34:35 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so1637210pbc.17
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 00:34:34 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id yh3si4869369pab.170.2014.06.19.00.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 19 Jun 2014 00:34:34 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7E000K3NPJXW70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 19 Jun 2014 08:34:31 +0100 (BST)
Message-id: <53A29158.2050809@samsung.com>
Date: Thu, 19 Jun 2014 11:29:28 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: slab.h: wrap the whole file with guarding macro
References: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.02.1406181321010.10339@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.02.1406181321010.10339@chino.kir.corp.google.com>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/19/14 00:22, David Rientjes wrote:
> On Wed, 18 Jun 2014, Andrey Ryabinin wrote:
> 
>> Guarding section:
>> 	#ifndef MM_SLAB_H
>> 	#define MM_SLAB_H
>> 	...
>> 	#endif
>> currently doesn't cover the whole mm/slab.h. It seems like it was
>> done unintentionally.
>>
>> Wrap the whole file by moving closing #endif to the end of it.
>>
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Looks like
> 
> ca34956b804b ("slab: Common definition for kmem_cache_node")
> e25839f67948 ("mm/slab: Sharing s_next and s_stop between slab and slub
> 276a2439ce79 ("mm/slab: Give s_next and s_stop slab-specific names")
> 
> added onto the header without the guard and it has been this way since 
> Jan 10 2013.  Andrey, how did you notice that this was an issue?  Simply 
> by visual inspection?
> 

I had to do some modifications in this file for some reasons, and for me it was hard to not
notice lack of endif in the end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

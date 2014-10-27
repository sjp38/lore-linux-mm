Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5CA6B0075
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:07:55 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so4196354pab.19
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 10:07:55 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id b1si10949821pdd.136.2014.10.27.10.07.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Oct 2014 10:07:54 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE400LT551Y07A0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 17:10:46 +0000 (GMT)
Message-id: <544E7BE6.8040102@samsung.com>
Date: Mon, 27 Oct 2014 20:07:50 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v5 07/12] mm: slub: share slab_err and object_err functions
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-8-git-send-email-a.ryabinin@samsung.com>
 <1414429203.8884.12.camel@perches.com>
In-reply-to: <1414429203.8884.12.camel@perches.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 10/27/2014 08:00 PM, Joe Perches wrote:
> On Mon, 2014-10-27 at 19:46 +0300, Andrey Ryabinin wrote:
>> Remove static and add function declarations to mm/slab.h so they
>> could be used by kernel address sanitizer.
> []
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> []
>> @@ -115,4 +115,8 @@ static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
> []
>> +void slab_err(struct kmem_cache *s, struct page *page, const char *fmt, ...);
>> +void object_err(struct kmem_cache *s, struct page *page,
>> +		u8 *object, char *reason);
> 
> Please add __printf(3, 4) to have the compiler catch
> format and argument mismatches.
> 
> 

Will do, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

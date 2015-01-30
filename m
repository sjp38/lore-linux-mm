Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3AB6B0032
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:17:48 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so53949534pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 08:17:48 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id or9si14065457pac.2.2015.01.30.08.17.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 30 Jan 2015 08:17:47 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ000MH404E6YA0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 30 Jan 2015 16:21:50 +0000 (GMT)
Message-id: <54CBAE9E.2090503@samsung.com>
Date: Fri, 30 Jan 2015 19:17:34 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v10 04/17] mm: slub: introduce virt_to_obj function.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-5-git-send-email-a.ryabinin@samsung.com>
 <20150129151234.a94bea44ae34bc90dcd148b0@linux-foundation.org>
In-reply-to: <20150129151234.a94bea44ae34bc90dcd148b0@linux-foundation.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On 01/30/2015 02:12 AM, Andrew Morton wrote:
> On Thu, 29 Jan 2015 18:11:48 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> virt_to_obj takes kmem_cache address, address of slab page,
>> address x pointing somewhere inside slab object,
>> and returns address of the begging of object.
> 
> "beginning"
> 
> The above text may as well be placed into slub_def.h as a comment.
> 

Ok.

>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>> Acked-by: Christoph Lameter <cl@linux.com>
>> ---
>>  include/linux/slub_def.h | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index 9abf04e..eca3883 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -110,4 +110,9 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
>>  }
>>  #endif
>>  
>> +static inline void *virt_to_obj(struct kmem_cache *s, void *slab_page, void *x)
>> +{
>> +	return x - ((x - slab_page) % s->size);
>> +}
> 
> "const void *x" would be better.
> 

Yep.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

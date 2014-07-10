Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9F89D6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 10:00:20 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so10940558pdi.27
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 07:00:20 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id oq8si48552177pab.231.2014.07.10.07.00.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 07:00:19 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8I00I701K0BO60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 15:00:00 +0100 (BST)
Message-id: <53BE9B25.6090906@samsung.com>
Date: Thu, 10 Jul 2014 17:54:45 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 03/21] x86: add kasan hooks fort
 memcpy/memmove/memset functions
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-4-git-send-email-a.ryabinin@samsung.com>
 <87ion6nxap.fsf@tassilo.jf.intel.com>
In-reply-to: <87ion6nxap.fsf@tassilo.jf.intel.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/14 23:31, Andi Kleen wrote:
> Andrey Ryabinin <a.ryabinin@samsung.com> writes:
>> +
>> +#undef memcpy
>> +void *kasan_memset(void *ptr, int val, size_t len);
>> +void *kasan_memcpy(void *dst, const void *src, size_t len);
>> +void *kasan_memmove(void *dst, const void *src, size_t len);
>> +
>> +#define memcpy(dst, src, len) kasan_memcpy((dst), (src), (len))
>> +#define memset(ptr, val, len) kasan_memset((ptr), (val), (len))
>> +#define memmove(dst, src, len) kasan_memmove((dst), (src), (len))
> 
> I don't think just define is enough, gcc can call these functions
> implicitely too (both with and without __). For example for a struct copy.
> 
> You need to have true linker level aliases. 
> 

It's true, but problem with linker aliases that they cannot be disabled for some files
we don't want to instrument.

> -Andi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4F06B0035
	for <linux-mm@kvack.org>; Sun, 13 Jul 2014 06:39:23 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id hu12so106596vcb.34
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 03:39:22 -0700 (PDT)
Received: from mail-vc0-x231.google.com (mail-vc0-x231.google.com [2607:f8b0:400c:c03::231])
        by mx.google.com with ESMTPS id te2si4319784vcb.101.2014.07.13.03.39.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 13 Jul 2014 03:39:22 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id ij19so5137303vcb.22
        for <linux-mm@kvack.org>; Sun, 13 Jul 2014 03:39:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53C08876.10209@zytor.com>
References: <1404903678-8257-1-git-send-email-a.ryabinin@samsung.com>
	<53C08876.10209@zytor.com>
Date: Sun, 13 Jul 2014 14:39:21 +0400
Message-ID: <CAPAsAGwb2sLmu0o_o-pFP5pXhMs-1sZSJbA3ji=W+JPOZRepgg@mail.gmail.com>
Subject: Re: [RFC/PATCH -next 00/21] Address sanitizer for kernel (kasan) -
 dynamic memory error detector.
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

2014-07-12 4:59 GMT+04:00 H. Peter Anvin <hpa@zytor.com>:
> On 07/09/2014 04:00 AM, Andrey Ryabinin wrote:
>>
>> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
>> mapping with a scale and offset to translate a memory address to its corresponding
>> shadow address.
>>
>> Here is function to translate address to corresponding shadow address:
>>
>>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>>      {
>>               return ((addr) >> KASAN_SHADOW_SCALE_SHIFT)
>>                            + kasan_shadow_start - (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT);
>>      }
>>
>> where KASAN_SHADOW_SCALE_SHIFT = 3.
>>
>
> How does that work when memory is sparsely populated?
>

Sparsemem configurations currently may not work with kasan.
I suppose I will have to move shadow area to vmalloc address space and
make it (shadow) sparse too if needed.

>         -hpa
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id EEAA06B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 20:59:52 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so2327552pad.35
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 17:59:52 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id v3si2018746pdp.256.2014.07.11.17.59.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 17:59:51 -0700 (PDT)
Message-ID: <53C08876.10209@zytor.com>
Date: Fri, 11 Jul 2014 17:59:34 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH -next 00/21] Address sanitizer for kernel (kasan)
 - dynamic memory error detector.
References: <1404903678-8257-1-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1404903678-8257-1-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/2014 04:00 AM, Andrey Ryabinin wrote:
> 
> Address sanitizer dedicates 1/8 of the low memory to the shadow memory and uses direct
> mapping with a scale and offset to translate a memory address to its corresponding
> shadow address.
> 
> Here is function to translate address to corresponding shadow address:
> 
>      unsigned long kasan_mem_to_shadow(unsigned long addr)
>      {
> 		return ((addr) >> KASAN_SHADOW_SCALE_SHIFT)
>        	             + kasan_shadow_start - (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT);
>      }
> 
> where KASAN_SHADOW_SCALE_SHIFT = 3.
> 

How does that work when memory is sparsely populated?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

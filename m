Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6986B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 04:50:27 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so10518068pdb.30
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 01:50:27 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id a8si1159539pdj.145.2014.07.10.01.50.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 01:50:26 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8H006KSN7RC280@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 09:50:15 +0100 (BST)
Message-id: <53BE528A.1080104@samsung.com>
Date: Thu, 10 Jul 2014 12:44:58 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 13/21] mm: slub: add allocation size field
 to struct kmem_cache
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-14-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.11.1407090933170.1384@gentwo.org>
In-reply-to: <alpine.DEB.2.11.1407090933170.1384@gentwo.org>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/14 18:33, Christoph Lameter wrote:
> On Wed, 9 Jul 2014, Andrey Ryabinin wrote:
> 
>> When caller creates new kmem_cache, requested size of kmem_cache
>> will be stored in alloc_size. Later alloc_size will be used by
>> kerenel address sanitizer to mark alloc_size of slab object as
>> accessible and the rest of its size as redzone.
> 
> I think this patch is not needed since object_size == alloc_size right?
> 

I vaguely remember there was a reason for this patch, but I can't see/recall it now.
Probably I misunderstood something. I'll drop this patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

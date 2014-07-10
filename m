Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AAEB56B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 03:46:45 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ey11so10672284pad.12
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 00:46:45 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ce14si8284990pdb.1.2014.07.10.00.46.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 10 Jul 2014 00:46:44 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8H003B8K9T3S70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 10 Jul 2014 08:46:41 +0100 (BST)
Message-id: <53BE4398.6020509@samsung.com>
Date: Thu, 10 Jul 2014 11:41:12 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH RESEND -next 11/21] mm: slub: share slab_err and
 object_err functions
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-12-git-send-email-a.ryabinin@samsung.com>
 <alpine.DEB.2.11.1407090928530.1384@gentwo.org>
In-reply-to: <alpine.DEB.2.11.1407090928530.1384@gentwo.org>
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On 07/09/14 18:29, Christoph Lameter wrote:
> On Wed, 9 Jul 2014, Andrey Ryabinin wrote:
> 
>> Remove static and add function declarations to mm/slab.h so they
>> could be used by kernel address sanitizer.
> 
> Hmmm... This is allocator specific. At some future point it would be good
> to move error reporting to slab_common.c and use those from all
> allocators.
> 

I could move declarations to kasan internals, but it will look ugly too.
I also had an idea about unifying SLAB_DEBUG and SLUB_DEBUG at some future.
I can't tell right now how hard it will be, but it seems doable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

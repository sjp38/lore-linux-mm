Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 707E26B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 10:48:46 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id e89so6567874qgf.15
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 07:48:46 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id t9si26913697qai.120.2014.07.09.07.48.44
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 07:48:45 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:48:41 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 15/21] mm: slub: add kernel address
 sanitizer hooks to slub allocator
In-Reply-To: <1404905415-9046-16-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1407090947020.1384@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-16-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 9 Jul 2014, Andrey Ryabinin wrote:

> With this patch kasan will be able to catch bugs in memory allocated
> by slub.
> Allocated slab page, this whole page marked as unaccessible
> in corresponding shadow memory.
> On allocation of slub object requested allocation size marked as
> accessible, and the rest of the object (including slub's metadata)
> marked as redzone (unaccessible).
>
> We also mark object as accessible if ksize was called for this object.
> There is some places in kernel where ksize function is called to inquire
> size of really allocated area. Such callers could validly access whole
> allocated memory, so it should be marked as accessible by kasan_krealloc call.

Do you really need to go through all of this? Add the hooks to
kmem_cache_alloc_trace() instead and use the existing instrumentation
that is there for other purposes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

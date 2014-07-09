Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 01B476B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 10:33:43 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id j5so6503281qga.9
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 07:33:43 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id t96si29628985qgd.15.2014.07.09.07.33.42
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 07:33:43 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:33:39 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 13/21] mm: slub: add allocation size
 field to struct kmem_cache
In-Reply-To: <1404905415-9046-14-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1407090933170.1384@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-14-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 9 Jul 2014, Andrey Ryabinin wrote:

> When caller creates new kmem_cache, requested size of kmem_cache
> will be stored in alloc_size. Later alloc_size will be used by
> kerenel address sanitizer to mark alloc_size of slab object as
> accessible and the rest of its size as redzone.

I think this patch is not needed since object_size == alloc_size right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

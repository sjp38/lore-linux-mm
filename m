Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id CC4B76B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 10:26:09 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id a108so6362501qge.32
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 07:26:09 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id d1si38007601qcd.28.2014.07.09.07.26.08
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 07:26:08 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:26:03 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 01/21] Add kernel address sanitizer
 infrastructure.
In-Reply-To: <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1407090924030.1384@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 9 Jul 2014, Andrey Ryabinin wrote:

> +
> +Markers of unaccessible bytes could be found in mm/kasan/kasan.h header:
> +
> +#define KASAN_FREE_PAGE         0xFF  /* page was freed */
> +#define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
> +#define KASAN_SLAB_REDZONE      0xFD  /* Slab page redzone, does not belong to any slub object */

We call these zones "PADDING". Redzones are associated with an object.
Padding is there because bytes are left over, unusable or necessary for
alignment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

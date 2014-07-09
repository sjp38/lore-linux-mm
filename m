Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 145B66B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 10:32:27 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id z60so6341868qgd.38
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 07:32:26 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id w7si59952505qaj.16.2014.07.09.07.32.25
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 07:32:25 -0700 (PDT)
Date: Wed, 9 Jul 2014 09:32:21 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 12/21] mm: util: move krealloc/kzfree
 to slab_common.c
In-Reply-To: <1404905415-9046-13-git-send-email-a.ryabinin@samsung.com>
Message-ID: <alpine.DEB.2.11.1407090931350.1384@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-13-git-send-email-a.ryabinin@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Wed, 9 Jul 2014, Andrey Ryabinin wrote:

> To avoid false positive reports in kernel address sanitizer krealloc/kzfree
> functions shouldn't be instrumented. Since we want to instrument other
> functions in mm/util.c, krealloc/kzfree moved to slab_common.c which is not
> instrumented.
>
> Unfortunately we can't completely disable instrumentation for one function.
> We could disable compiler's instrumentation for one function by using
> __atribute__((no_sanitize_address)).
> But the problem here is that memset call will be replaced by instumented
> version kasan_memset since currently it's implemented as define:

Looks good to me and useful regardless of the sanitizer going in.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

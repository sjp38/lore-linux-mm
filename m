Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id A7B1C6B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 10:07:58 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id 63so816248qgz.8
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 07:07:58 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id d5si61113711qar.108.2014.07.10.07.07.56
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 07:07:57 -0700 (PDT)
Date: Thu, 10 Jul 2014 09:07:53 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH RESEND -next 11/21] mm: slub: share slab_err and
 object_err functions
In-Reply-To: <53BE4398.6020509@samsung.com>
Message-ID: <alpine.DEB.2.11.1407100907131.12483@gentwo.org>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1404905415-9046-12-git-send-email-a.ryabinin@samsung.com> <alpine.DEB.2.11.1407090928530.1384@gentwo.org> <53BE4398.6020509@samsung.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Thu, 10 Jul 2014, Andrey Ryabinin wrote:

> On 07/09/14 18:29, Christoph Lameter wrote:
> > On Wed, 9 Jul 2014, Andrey Ryabinin wrote:
> >
> >> Remove static and add function declarations to mm/slab.h so they
> >> could be used by kernel address sanitizer.
> >
> > Hmmm... This is allocator specific. At some future point it would be good
> > to move error reporting to slab_common.c and use those from all
> > allocators.
> >
>
> I could move declarations to kasan internals, but it will look ugly too.
> I also had an idea about unifying SLAB_DEBUG and SLUB_DEBUG at some future.
> I can't tell right now how hard it will be, but it seems doable.

Well the simple approach is to first unify the reporting functions and
then work the way up to higher levels. The reporting functions could also
be more generalized to be more useful for multiple checking tools.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3F10B6B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 11:14:01 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id 63so3476810qgz.22
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 08:14:01 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id q9si15698957qar.47.2014.07.14.08.14.00
        for <linux-mm@kvack.org>;
        Mon, 14 Jul 2014 08:14:00 -0700 (PDT)
Date: Mon, 14 Jul 2014 10:13:56 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC/PATCH -next 00/21] Address sanitizer for kernel (kasan) -
 dynamic memory error detector.
In-Reply-To: <CAPAsAGwb2sLmu0o_o-pFP5pXhMs-1sZSJbA3ji=W+JPOZRepgg@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1407141012520.25405@gentwo.org>
References: <1404903678-8257-1-git-send-email-a.ryabinin@samsung.com> <53C08876.10209@zytor.com> <CAPAsAGwb2sLmu0o_o-pFP5pXhMs-1sZSJbA3ji=W+JPOZRepgg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Sun, 13 Jul 2014, Andrey Ryabinin wrote:

> > How does that work when memory is sparsely populated?
> >
>
> Sparsemem configurations currently may not work with kasan.
> I suppose I will have to move shadow area to vmalloc address space and
> make it (shadow) sparse too if needed.

Well it seems to work with sparsemem / vmemmap? So non vmmemmapped configs
of sparsemem only. vmemmmap can also handle holes in memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

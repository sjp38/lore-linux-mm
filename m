Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0846B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:41:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so604035wmf.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:41:39 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id q199si14315559lfd.113.2016.05.27.10.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:41:38 -0700 (PDT)
Received: by mail-lb0-x233.google.com with SMTP id ww9so33203286lbc.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:41:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1605271229330.30511@east.gentwo.org>
References: <1464369240-35844-1-git-send-email-glider@google.com> <alpine.DEB.2.20.1605271229330.30511@east.gentwo.org>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 27 May 2016 19:41:37 +0200
Message-ID: <CAG_fn=V5pTXzPvRGd4PfGp33q8dD7gyNRF8p9W+JXS054Y+RXw@mail.gmail.com>
Subject: Re: [PATCH v1] [mm] Set page->slab_cache for every page allocated for
 a kmem_cache.
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, May 27, 2016 at 7:30 PM, Christoph Lameter <cl@linux.com> wrote:
> On Fri, 27 May 2016, Alexander Potapenko wrote:
>
>> It's reasonable to rely on the fact that for every page allocated for a
>> kmem_cache the |slab_cache| field points to that cache. Without that it'=
s
>> hard to figure out which cache does an allocated object belong to.
>
> The flags are set only in the head page of a coumpound page which is used
> by SLAB. No need to do this. This would just mean unnecessarily dirtying
> struct page cachelines on allocation.
>

Got it, thank you.
Looks like I just need to make sure my code uses
virt_to_head_page()->page_slab to get the cache for an object.

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

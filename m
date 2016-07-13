Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 905BD6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:14:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so31877153lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:14:21 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id u80si362500lfd.91.2016.07.13.05.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 05:14:20 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id b199so38003777lfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:14:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160712130201.9339f7dbc9575d2c0cb31aeb@linux-foundation.org>
References: <1468347165-41906-1-git-send-email-glider@google.com>
 <1468347165-41906-2-git-send-email-glider@google.com> <20160712130201.9339f7dbc9575d2c0cb31aeb@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 13 Jul 2016 14:14:19 +0200
Message-ID: <CAG_fn=V4B4g=ZEdwR7SDiRsjqhOsKiLys_YQ+nFKYJup7ZRGpQ@mail.gmail.com>
Subject: Re: [PATCH v7 1/2] mm, kasan: account for object redzone in SLUB's nearest_obj()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Joonsoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Changed the description as follows:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
    mm, kasan: account for object redzone in SLUB's nearest_obj()

    When looking up the nearest SLUB object for a given address, correctly
    calculate its offset if SLAB_RED_ZONE is enabled for that cache.

    Previously, when KASAN had detected an error on an object from a cache
    with SLAB_RED_ZONE set, the actual start address of the object was
    miscalculated, which led to random stacks having been reported.

    Fixes: 7ed2f9e663854db ("mm, kasan: SLAB support")
    Signed-off-by: Alexander Potapenko <glider@google.com>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D

To avoid sending both patches and the cover page again, I'm going to
wait for other comments.

On Tue, Jul 12, 2016 at 10:02 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 12 Jul 2016 20:12:44 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
>> When looking up the nearest SLUB object for a given address, correctly
>> calculate its offset if SLAB_RED_ZONE is enabled for that cache.
>
> What are the runtime effects of this fix?  Please always include this
> info when fixing bugs so that others can decide which kernel(s) need
> patching.
>



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

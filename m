Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 753C06B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 14:59:12 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o68-v6so8262251qte.0
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 11:59:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b190-v6sor4246468qkg.98.2018.06.15.11.59.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 11:59:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180606194144.16990-1-malat@debian.org>
References: <20180606194144.16990-1-malat@debian.org>
From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 15 Jun 2018 11:59:10 -0700
Message-ID: <CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Malaterre <malat@debian.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Jun 6, 2018 at 12:41 PM, Mathieu Malaterre <malat@debian.org> wrote=
:
> Commit 26f09e9b3a06 ("mm/memblock: add memblock memory allocation apis")
> introduced two new function definitions:
>   =E2=80=98memblock_virt_alloc_try_nid_nopanic=E2=80=99
> and
>   =E2=80=98memblock_virt_alloc_try_nid=E2=80=99.
> Commit ea1f5f3712af ("mm: define memblock_virt_alloc_try_nid_raw")
> introduced the following function definition:
>   =E2=80=98memblock_virt_alloc_try_nid_raw=E2=80=99
>
> This commit adds an includeof header file <linux/bootmem.h> to provide th=
e
> missing function prototypes. Silence the following gcc warning (W=3D1):
>
>   mm/memblock.c:1334:15: warning: no previous prototype for =E2=80=98memb=
lock_virt_alloc_try_nid_raw=E2=80=99 [-Wmissing-prototypes]
>   mm/memblock.c:1371:15: warning: no previous prototype for =E2=80=98memb=
lock_virt_alloc_try_nid_nopanic=E2=80=99 [-Wmissing-prototypes]
>   mm/memblock.c:1407:15: warning: no previous prototype for =E2=80=98memb=
lock_virt_alloc_try_nid=E2=80=99 [-Wmissing-prototypes]
>
> Signed-off-by: Mathieu Malaterre <malat@debian.org>

Sadly that breaks ia64 build:

  CC      mm/memblock.o
mm/memblock.c:1340: error: redefinition of =E2=80=98memblock_virt_alloc_try=
_nid_raw=E2=80=99
./include/linux/bootmem.h:335: error: previous definition of
=E2=80=98memblock_virt_alloc_try_nid_raw=E2=80=99 was here
mm/memblock.c:1377: error: redefinition of =E2=80=98memblock_virt_alloc_try=
_nid_nopanic=E2=80=99
./include/linux/bootmem.h:343: error: previous definition of
=E2=80=98memblock_virt_alloc_try_nid_nopanic=E2=80=99 was here
mm/memblock.c:1413: error: redefinition of =E2=80=98memblock_virt_alloc_try=
_nid=E2=80=99
./include/linux/bootmem.h:327: error: previous definition of
=E2=80=98memblock_virt_alloc_try_nid=E2=80=99 was here
make[1]: *** [mm/memblock.o] Error 1
make: *** [mm/memblock.o] Error 2

-Tony

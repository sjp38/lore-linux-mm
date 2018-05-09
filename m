Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 28AF06B02F8
	for <linux-mm@kvack.org>; Wed,  9 May 2018 05:16:17 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id v145-v6so27785693vkv.17
        for <linux-mm@kvack.org>; Wed, 09 May 2018 02:16:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n196-v6sor13042250vkd.282.2018.05.09.02.16.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 02:16:15 -0700 (PDT)
MIME-Version: 1.0
References: <20180508162829.7729-1-glider@google.com> <20180508214445.lnqbct6dgrhyxp4a@black.fi.intel.com>
In-Reply-To: <20180508214445.lnqbct6dgrhyxp4a@black.fi.intel.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 09 May 2018 09:16:03 +0000
Message-ID: <CAG_fn=UrQw4qRofUgHb4A_j4hbuefSwGtFMfCtYS318HWXFSFA@mail.gmail.com>
Subject: Re: [PATCH v2] x86/boot/64/clang: Use fixup_pointer() to access '__supported_pte_mask'
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: dave.hansen@linux.intel.com, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matthias Kaehlcke <mka@chromium.org>, Dmitriy Vyukov <dvyukov@google.com>, Michael Davidson <md@google.com>

On Tue, May 8, 2018 at 11:44 PM Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> On Tue, May 08, 2018 at 04:28:29PM +0000, Alexander Potapenko wrote:
> > @@ -196,7 +204,8 @@ unsigned long __head __startup_64(unsigned long
physaddr,
> >
> >       pmd_entry =3D __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
> >       /* Filter out unsupported __PAGE_KERNEL_* bits: */
> > -     pmd_entry &=3D __supported_pte_mask;
> > +     mask_ptr =3D (pteval_t *)fixup_pointer(&__supported_pte_mask,
physaddr);

> Do we really need the cast here?
Correct, we do not.

> --
>   Kirill A. Shutemov



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

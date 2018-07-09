Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBDF36B02E3
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 10:23:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w21-v6so7074644wmc.6
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 07:23:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 89-v6sor1000491wra.75.2018.07.09.07.23.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 07:23:50 -0700 (PDT)
MIME-Version: 1.0
References: <CGME20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29@eucas1p2.samsung.com>
 <20180709121956.20200-1-m.szyprowski@samsung.com> <20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29~-sqTPJKij2939229392eucas1p2j@eucas1p2.samsung.com>
In-Reply-To: <20180709122019eucas1p2340da484acfcc932537e6014f4fd2c29~-sqTPJKij2939229392eucas1p2j@eucas1p2.samsung.com>
From: =?UTF-8?Q?Micha=C5=82_Nazarewicz?= <mina86@mina86.com>
Date: Mon, 9 Jul 2018 15:23:38 +0100
Message-ID: <CA+pa1O2H-rbTqgKgtSzD9jdnyxkD5w62b0Q=o5FX5Y85hCGVnA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/cma: remove unsupported gfp_mask parameter from cma_alloc()
Content-Type: multipart/alternative; boundary="000000000000277366057091c3be"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

--000000000000277366057091c3be
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 9 Jul 2018 13:20 Marek Szyprowski, <m.szyprowski@samsung.com> wrote=
:

> cma_alloc() function doesn't really support gfp flags other than
> __GFP_NOWARN, so convert gfp_mask parameter to boolean no_warn parameter.
>
> This will help to avoid giving false feeling that this function supports
> standard gfp flags and callers can pass __GFP_ZERO to get zeroed buffer,
> what has already been an issue: see commit dd65a941f6ba ("arm64:
> dma-mapping: clear buffers allocated with FORCE_CONTIGUOUS flag").
>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
>

Acked-by: Micha=C5=82 Nazarewicz <mina86@mina86.com>

(Adding Acked-by on a phone is surprisingly hard).

---
>  arch/powerpc/kvm/book3s_hv_builtin.c       | 2 +-
>  drivers/s390/char/vmcp.c                   | 2 +-
>  drivers/staging/android/ion/ion_cma_heap.c | 2 +-
>  include/linux/cma.h                        | 2 +-
>  kernel/dma/contiguous.c                    | 3 ++-
>  mm/cma.c                                   | 8 ++++----
>  mm/cma_debug.c                             | 2 +-
>  7 files changed, 11 insertions(+), 10 deletions(-)
>

--000000000000277366057091c3be
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><div class=3D"gmail_quote"><div dir=3D"ltr">On Mon, =
9 Jul 2018 13:20 Marek Szyprowski, &lt;<a href=3D"mailto:m.szyprowski@samsu=
ng.com" target=3D"_blank" rel=3D"noreferrer">m.szyprowski@samsung.com</a>&g=
t; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex">cma_alloc() function does=
n&#39;t really support gfp flags other than<br>
__GFP_NOWARN, so convert gfp_mask parameter to boolean no_warn parameter.<b=
r>
<br>
This will help to avoid giving false feeling that this function supports<br=
>
standard gfp flags and callers can pass __GFP_ZERO to get zeroed buffer,<br=
>
what has already been an issue: see commit dd65a941f6ba (&quot;arm64:<br>
dma-mapping: clear buffers allocated with FORCE_CONTIGUOUS flag&quot;).<br>
<br>
Signed-off-by: Marek Szyprowski &lt;<a href=3D"mailto:m.szyprowski@samsung.=
com" rel=3D"noreferrer noreferrer" target=3D"_blank">m.szyprowski@samsung.c=
om</a>&gt;<br></blockquote></div></div><div dir=3D"auto"><br></div><div dir=
=3D"auto">Acked-by: Micha=C5=82 Nazarewicz &lt;<a href=3D"mailto:mina86@min=
a86.com" target=3D"_blank" rel=3D"noreferrer">mina86@mina86.com</a>&gt;</di=
v><div dir=3D"auto"><br></div><div dir=3D"auto">(Adding Acked-by on a phone=
 is surprisingly hard).=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"=
auto"><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
---<br>
=C2=A0arch/powerpc/kvm/book3s_hv_builtin.c=C2=A0 =C2=A0 =C2=A0 =C2=A0| 2 +-=
<br>
=C2=A0drivers/s390/char/vmcp.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| 2 +-<br>
=C2=A0drivers/staging/android/ion/ion_cma_heap.c | 2 +-<br>
=C2=A0include/linux/cma.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 2 +-<br>
=C2=A0kernel/dma/contiguous.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | 3 ++-<br>
=C2=A0mm/cma.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 8 ++++-=
---<br>
=C2=A0mm/cma_debug.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 2 +-<br>
=C2=A07 files changed, 11 insertions(+), 10 deletions(-)<br></blockquote></=
div></div></div>

--000000000000277366057091c3be--

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id C66582802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 15:32:55 -0400 (EDT)
Received: by oiyy130 with SMTP id y130so125555561oiy.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 12:32:55 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id az3si14438341obb.45.2015.07.06.12.32.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 12:32:55 -0700 (PDT)
Received: by oiab3 with SMTP id b3so7265641oia.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 12:32:54 -0700 (PDT)
MIME-Version: 1.0
From: Sumit Gupta <sumit.g.007@gmail.com>
Date: Tue, 7 Jul 2015 01:02:15 +0530
Message-ID: <CANDtUrcogw-CWPQBjHunhJRLGae2F3+g1D2oyF__wAp42PTKYw@mail.gmail.com>
Subject: MM: Query about different memory types(mem_types)__mmu.c
Content-Type: multipart/alternative; boundary=089e013d085ae64b4a051a39f8f6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

--089e013d085ae64b4a051a39f8f6
Content-Type: text/plain; charset=UTF-8

Hi All,

I have been exploring ARM reference manual about ARM weak memory model and
mmu page table setting from some time.
I think i understand different memory types, mmu settings for page/section,
TEX, AP, B, C, S bits well.
My target is to to dig further and fully understand setting of all
parameters for different memory types in ARM
[File mmu.c: "static struct mem_type mem_types"].

But i am not able to find any good source to refer for fully understanding
all below parameters.
Could you please help me to understand mappings for below mem types. If you
can point me to some references which can help me understand more.

Thankyou in advance for your help.


        [MT_DEVICE] = {           /* Strongly ordered / ARMv6 shared device
*/
                .prot_pte       = PROT_PTE_DEVICE | L_PTE_MT_DEV_SHARED |
                                  L_PTE_SHARED,
                .prot_pte_s2    = s2_policy(PROT_PTE_S2_DEVICE) |
                                  s2_policy(L_PTE_S2_MT_DEV_SHARED) |
                                  L_PTE_SHARED,
                .prot_l1        = PMD_TYPE_TABLE,
                .prot_sect      = PROT_SECT_DEVICE | PMD_SECT_S,
                .domain         = DOMAIN_IO,
        },
............
       [MT_MEMORY_RW] = {
                .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                             L_PTE_XN,
                .prot_l1   = PMD_TYPE_TABLE,
                .prot_sect = PMD_TYPE_SECT | PMD_SECT_AP_WRITE,
                .domain    = DOMAIN_KERNEL,
        },
............
        [MT_MEMORY_DMA_READY] = {
                .prot_pte  = L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_DIRTY |
                                L_PTE_XN,
                .prot_l1   = PMD_TYPE_TABLE,
                .domain    = DOMAIN_KERNEL,
        },

Regards,
Sumit Gupta

--089e013d085ae64b4a051a39f8f6
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div style=3D"font-size:12.8000001907349px">Hi All,</div><=
div style=3D"font-size:12.8000001907349px"><br></div><div style=3D"font-siz=
e:12.8000001907349px">I have been exploring ARM reference manual about ARM =
weak memory model and mmu page table setting from some time.=C2=A0</div><di=
v style=3D"font-size:12.8000001907349px"><span style=3D"font-size:12.800000=
1907349px">I think i understand different memory types, mmu settings for pa=
ge/section, TEX, AP, B, C, S bits well.</span></div><div style=3D"font-size=
:12.8000001907349px">My target is to to dig further and fully understand se=
tting of all parameters for different memory types in ARM</div><div style=
=3D"font-size:12.8000001907349px">[File mmu.c: &quot;static struct mem_type=
 mem_types&quot;].=C2=A0</div><div style=3D"font-size:12.8000001907349px"><=
br></div><div style=3D"font-size:12.8000001907349px">But i am not able to f=
ind any good source to refer for fully understanding all below parameters.<=
/div><div style=3D"font-size:12.8000001907349px">Could you please help me t=
o understand mappings for below mem types. If you can point me to some refe=
rences which can help me understand more.</div><div style=3D"font-size:12.8=
000001907349px"><br></div><div style=3D"font-size:12.8000001907349px">Thank=
you in advance for your help.</div><div style=3D"font-size:12.8000001907349=
px"><br></div><div style=3D"font-size:12.8000001907349px"><br></div><div st=
yle=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 [MT_DEVICE=
] =3D { =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Strongly ordered / ARMv6 shar=
ed device */</div><div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .prot_pte =C2=A0 =C2=A0 =C2=A0 =
=3D PROT_PTE_DEVICE | L_PTE_MT_DEV_SHARED |</div><div style=3D"font-size:12=
.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 L_PTE_SHARED=
,</div><div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .prot_pte_s2 =C2=A0 =C2=A0=3D s2_policy(PRO=
T_PTE_S2_DEVICE) |</div><div style=3D"font-size:12.8000001907349px">=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s2_policy(L_PTE_S2_MT_DEV_SHARED) |<=
/div><div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 L_PTE_SHARED,</div><div style=3D"font-size:12.80000019=
07349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .prot_l1 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0=3D PMD_TYPE_TABLE,</div><div style=3D"font-size=
:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 .prot_sect =C2=A0 =C2=A0 =C2=A0=3D PROT_SECT_DEVICE | PMD_SECT_S,</div>=
<div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 .domain =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D DOMAIN_IO,=
</div><div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 },</div><div style=3D"font-size:12.8000001907349px">............</div><=
div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0[MT_M=
EMORY_RW] =3D {</div><div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .prot_pte =C2=A0=3D L_PTE_PRE=
SENT | L_PTE_YOUNG | L_PTE_DIRTY |</div><div style=3D"font-size:12.80000019=
07349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0L_PTE_XN,</div><div style=3D"font-siz=
e:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 .prot_l1 =C2=A0 =3D PMD_TYPE_TABLE,</div><div style=3D"font-size:12.800=
0001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .prot=
_sect =3D PMD_TYPE_SECT | PMD_SECT_AP_WRITE,</div><div style=3D"font-size:1=
2.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
.domain =C2=A0 =C2=A0=3D DOMAIN_KERNEL,</div><div style=3D"font-size:12.800=
0001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 },</div><div style=3D"font-size:1=
2.8000001907349px">............</div><div style=3D"font-size:12.80000019073=
49px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 [MT_MEMORY_DMA_READY] =3D {</div><div sty=
le=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 .prot_pte =C2=A0=3D L_PTE_PRESENT | L_PTE_YOUNG | L_PTE_D=
IRTY |</div><div style=3D"font-size:12.8000001907349px">=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 L_PTE_XN,</div><div style=3D"font-size:12.800000190734=
9px">=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .prot_l1 =C2=
=A0 =3D PMD_TYPE_TABLE,</div><div style=3D"font-size:12.8000001907349px">=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .domain =C2=A0 =C2=
=A0=3D DOMAIN_KERNEL,</div><div style=3D"font-size:12.8000001907349px">=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 },</div><div style=3D"font-size:12.8000001907349px=
"><br></div><div style=3D"font-size:12.8000001907349px">Regards,</div><div =
style=3D"font-size:12.8000001907349px">Sumit Gupta</div><div style=3D"font-=
size:12.8000001907349px"><br></div></div>

--089e013d085ae64b4a051a39f8f6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

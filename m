Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3BBCC742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 18:31:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7976C205ED
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 18:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ewlHia7h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7976C205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFCBE8E0164; Fri, 12 Jul 2019 14:31:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A859B8E0003; Fri, 12 Jul 2019 14:31:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94DA08E0164; Fri, 12 Jul 2019 14:31:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68BD88E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 14:31:09 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id c21so1455768uao.21
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:31:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=cIV6rBtWLOPRszoGLvj5E27EPDYcnDtLD4/tbfFhpvo=;
        b=Fs+ousP+v2QgFJIzLNnHGFqDIhCotdoKlip+ivz3xWFjWqGTBf0cyvKAB9Q8qhfisy
         VIHoL1zFXSgCeohsK2lGpN4WjrPT7OB/mWUYmxkB9Xsc7piKR8H8qRlQ5yFXyGrw9sBv
         XLJCaTDQyBSPqP86iPlXYvniZsLway1IM8fr+do55rRWsgxM6pGyHCQRFaxOEgiZfqOm
         obfC0yigTqog9Ay8XPc+nzqUiwiJrSFk9LW+kD/VtFnNZhvqlBIzpvx0ha2ZT+jF9uIM
         ekbNhVJdqUykjJQAKOZinQcfMsGxenv04ajwdr7V+Ps/ZpUKeAtzZJLzTDOVcpjCYTdz
         525w==
X-Gm-Message-State: APjAAAUzKBqaSjoB0C7XBH5kHf6h5aymgTuamrsS6bW32gPlx5OwQyOt
	YwBMzA+ATuFNnVmnlGR/qe/U9fCvViMuRMGt7mdGMceryexJuqVfTkx6BU+2mq5DibiO82q3+mf
	vVBQ03sbb1YbRk2O7M5lVlWnjkzya/BioVFze5vZ1lFMyhyaO1ya18o1c1eqOH+7kow==
X-Received: by 2002:a05:6102:3c8:: with SMTP id n8mr9227888vsq.135.1562956268961;
        Fri, 12 Jul 2019 11:31:08 -0700 (PDT)
X-Received: by 2002:a05:6102:3c8:: with SMTP id n8mr9227857vsq.135.1562956268187;
        Fri, 12 Jul 2019 11:31:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562956268; cv=none;
        d=google.com; s=arc-20160816;
        b=u7b5OPW3X2SeBklY+KMZr/LbqzIT3a9dOJ3AVlJaNyg+GtLkiIOwts98JfrE6vemKz
         ZiM/vQGgTUDx7Fr55T13PFYWweSQFUVlVtA8khw836L9BHBeLeMK+DBicyLzXfE1iHAm
         OnIMiQB3kWCp42TOOZ03RvrMNWryr4mqNl3ty4Bm4ZGe9Pj1VAM5us2m3UKnVjp8oxwW
         07pcq5vy29Ix5zAFmj9+Xi18C6/5kIrfpe3UE1GYTY/AN7A9MoLhJ9oCMEXOFfameKEn
         pT/rgIM7ywl4QxYhluuXGmfX3ssZ7XzqXrhhP19Q9s9ffdrttFoNZMgH4A3z9jMY8FBK
         Ef+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=cIV6rBtWLOPRszoGLvj5E27EPDYcnDtLD4/tbfFhpvo=;
        b=uAmct8/yhkOEoR+hpoU9W+L1NQJ34L+/jPOWzRc3nyz5wESXRnapHzvV3y+pl1Nusc
         ALbe1nIDESMatQymavH6FSY6MgJTBG+BLmxxcLhvexUusfDXYJBE63oHaXZYCYxOVTZG
         2kZu0zIzxqRRdpCDOJabqvPnRE8hTyaiMtrsotQXQqqZSDMi6ce8/iH1ZSxpC+UBEKGL
         FVOnHKPbGpXTMFlwRB4rSfFPn1ISh6Ry6MoqtkSxgE+UNe4aywwRp2muU8xOZQ1I2cow
         8Vr0GMc0ISrltgkoaZIcCDeg3RViRs/AQ+OVqSp/keVsfhbta+Q6mYoGhn8/wEEXjd4o
         0qrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ewlHia7h;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g15sor2970430vkk.44.2019.07.12.11.31.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 11:31:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ewlHia7h;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=cIV6rBtWLOPRszoGLvj5E27EPDYcnDtLD4/tbfFhpvo=;
        b=ewlHia7heeXX9gEvyayde5mx7+AEFE0O5WkRam9jXzXTM/cF4Rro/laOPuQDFADMkT
         pgBCEH82Sq2vQ5ytflI6aY9ECob3kCsDLkBEomA3BoZout9U7Tkh8v3UE+GqetFYgZwv
         T9i5nUr03L9NNnlgh1av/pQ5TwsQVLAfpkfba/uE0+COO/CT7rM4kTujCxnHZ/jfmRvl
         Ha6cWu/ktyCI4B3Ir3wy+Td4QeX9+knTOY4KmhVoy866xKmqHKB7yJFGampkVPjO1EH4
         syIDycrhKY/v7I3cqPWeNoNwRIu14RMQ2H5DNvB4fr8fphQAmDKq04wf+IpE1qy8dZZV
         aODA==
X-Google-Smtp-Source: APXvYqwoOrs4KeF1E3Iz5G6XucPUIl+s2QlAoOR993+Fq0+SJIKbbL4lgPIPTE2VQvtDIDsJPH41GoubeuVBEnQGkuo=
X-Received: by 2002:a1f:62c3:: with SMTP id w186mr6618726vkb.82.1562956267589;
 Fri, 12 Jul 2019 11:31:07 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Sat, 13 Jul 2019 00:00:56 +0530
Message-ID: <CACDBo56EoKca9FJCnbztWZAARdUQs+B=dmCs+UxW27yHNu5pzQ@mail.gmail.com>
Subject: cma_remap when using dma_alloc_attr :- DMA_ATTR_NO_KERNEL_MAPPING
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	iommu@lists.linux-foundation.org, Vlastimil Babka <vbabka@suse.cz>, 
	Robin Murphy <robin.murphy@arm.com>, Michal Hocko <mhocko@kernel.org>, 
	pankaj.suryawanshi@einfochips.com, minchan@kernel.org, minchan.kim@gmail.com
Content-Type: multipart/alternative; boundary="0000000000002114d7058d801d4a"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000002114d7058d801d4a
Content-Type: text/plain; charset="UTF-8"

Hello,

When we allocate cma memory using dma_alloc_attr using
DMA_ATTR_NO_KERNEL_MAPPING attribute. It will return physical address
without virtual mapping and thats the use case of this attribute. but lets
say some vpu/gpu drivers required virtual mapping of some part of the
allocation. then we dont have anything to remap that allocated memory to
virtual memory. and in 32-bit system it difficult for devices like android
to work all the time with virtual mapping, it degrade the performance.

For Example :

Lets say 4k video allocation required 300MB cma memory but not required
virtual mapping for all the 300MB, its require only 20MB virtually mapped
at some specific use case/point of video, and unmap virtual mapping after
uses, at that time this functions will be useful, it works like ioremap()
for cma_alloc() using dma apis.

/*
         * function call(s) to create virtual map of given physical memory
         * range [base, base+size) of CMA memory.
*/
void *cma_remap(__u32 base, __u32 size)
{
        struct page *page = phys_to_page(base);
        void *virt;

        pr_debug("cma: request to map 0x%08x for size 0x%08x\n",
                        base, size);

        size = PAGE_ALIGN(size);

        pgprot_t prot = get_dma_pgprot(DMA_ATTR, PAGE_KERNEL);

        if (PageHighMem(page)){
                virt = dma_alloc_remap(page, size, GFP_KERNEL, prot,
__builtin_return_address(0));
        }
        else
        {
                dma_remap(page, size, prot);
                virt = page_address(page);
        }

        if (!virt)
                pr_err("\x1b[31m" " cma: failed to map 0x%08x" "\x1b[0m\n",
                                base);
        else
                pr_debug("cma: 0x%08x is virtually mapped to 0x%08x\n",
                                base, (__u32) virt);

        return virt;
}

/*
         * function call(s) to remove virtual map of given virtual memory
         * range [virt, virt+size) of CMA memory.
*/

void cma_unmap(void *virt, __u32 size)
{
        size = PAGE_ALIGN(size);
        unsigned long pfn = virt_to_pfn(virt);
        struct page *page = pfn_to_page(pfn);

                if (PageHighMem(page))
                        dma_free_remap(virt, size);
                else
                        dma_remap(page, size, PAGE_KERNEL);

        pr_debug(" cma: virtual address 0x%08x is unmapped\n",
                        (__u32) virt);
}

This functions should be added in arch/arm/mm/dma-mapping.c file.

Please let me know if i am missing anything.

Regards,
Pankaj

--0000000000002114d7058d801d4a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>When we allocate cma memory using dma_alloc_=
attr using DMA_ATTR_NO_KERNEL_MAPPING attribute. It will return physical ad=
dress without virtual mapping and thats the use case of this attribute. but=
 lets say some vpu/gpu drivers required virtual mapping of some part of the=
 allocation. then we dont have anything to remap that allocated memory to v=
irtual memory. and in 32-bit system it difficult for devices like android t=
o work all the time with virtual mapping, it degrade the performance.<br><b=
r>For Example :<br><br>Lets say 4k video allocation required 300MB cma memo=
ry but not required virtual mapping for all the 300MB, its require only 20M=
B virtually mapped at some specific use case/point of video, and unmap virt=
ual mapping after uses, at that time this functions will be useful, it work=
s like ioremap() for cma_alloc() using dma apis.<br><br>/*<br>=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0* function call(s) to create virtual map of given phys=
ical memory<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* range [base, base+size) =
of CMA memory.<br>*/<br>void *cma_remap(__u32 base, __u32 size)<br>{<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page =3D phys_to_page(base);<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 void *virt;<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_=
debug(&quot;cma: request to map 0x%08x for size 0x%08x\n&quot;,<br>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 base, size);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 size =3D PAGE_ALIGN(siz=
e);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 pgprot_t prot =3D get_dma_pgprot(DMA=
_ATTR, PAGE_KERNEL);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageHighMem(pag=
e)){<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 virt =3D dm=
a_alloc_remap(page, size, GFP_KERNEL, prot, __builtin_return_address(0));<b=
r>=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 else<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 {<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dma_remap(page, size, prot);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 virt =3D page_address(page);<br>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 }<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!virt)<br>=C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err(&quot;\x1b[31m&quot; &quo=
t; cma: failed to map 0x%08x&quot; &quot;\x1b[0m\n&quot;,<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 base);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 else<br>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_debug(&quot;cma: 0x=
%08x is virtually mapped to 0x%08x\n&quot;,<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 base, (__u32) virt);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 return v=
irt;<br>}<br><br>/*<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* function call(s)=
 to remove virtual map of given virtual memory<br>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* range [virt, virt+size) of CMA memory.<br>*/<br><br>void cma_un=
map(void *virt, __u32 size)<br>{<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 size =3D PA=
GE_ALIGN(size);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long pfn =3D virt_t=
o_pfn(virt);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page =3D pfn_to_pa=
ge(pfn);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if =
(PageHighMem(page))<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dma_free_remap(virt, size);<br>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dma_remap(pa=
ge, size, PAGE_KERNEL);<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_debug(&quot; =
cma: virtual address 0x%08x is unmapped\n&quot;,<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (__u32) virt=
);<br>}<br><br><div>This functions should be added in arch/arm/mm/dma-mappi=
ng.c file.</div><div><br></div><div>Please let me know if i am missing anyt=
hing.</div><div><br></div><div>Regards,</div><div>Pankaj<br></div></div>

--0000000000002114d7058d801d4a--


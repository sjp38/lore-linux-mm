Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C219C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:25:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B20A22075B
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:25:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZzSiAq60"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B20A22075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BC008E00DF; Mon, 11 Feb 2019 07:25:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46CE48E00DD; Mon, 11 Feb 2019 07:25:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 336468E00DF; Mon, 11 Feb 2019 07:25:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7EB88E00DD
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:25:37 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f3so8210643pgq.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:25:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=sCyib29/TDyxQaimgzlPTWBxPHLjbGAY4DKzfFTRAWk=;
        b=qqVeM41uQeA8xWaNS0Jaha/5WZpaOEX9wbSWeaeNQcP3xzuu2Y5HlGqgyTEolOaQ12
         5CZliskb/Ih1VObDQdud1J/mrcXotk2tDDLWzxAeEYehcMkHSFKuxJrgNwLPVfoKzAwa
         Dv6EwF+G83JuMMWn0dcGvnsXMLENhSNvGInfX+JQI9q3cU6VLt2fYHmYtIX0r7yY0EQ5
         04xVrOYSk3qfcWU7X4uLxcdtqu4tU90RdoXlyQP4abfGayDrie1S3h6Ib9ez1luplmjL
         4K6tkTEzLWu7B8BzOHt2V1UIpBbtFwTe3w3ra57eZHY+3PMj2sio4mt/6DNDJ23jC5cB
         O65A==
X-Gm-Message-State: AHQUAubtYXGn9XBnufA2f7Fo6dZj5c0glkNZ0u6ZgCb0wgvpzxxYcczg
	JeJq5EegoTXOeh4KXDcjHPhMjj7FSoGZhFe6QEB2RxqwjDjAOC87k2KngSqtm3pSedBoa0uAYKx
	1FZTWY4xSPTJf62W03b8vpm2p6fQwU3s9pa7s9rhHj6uYbf6vLk/ZHNn0bv9tT30O3FgXG+j1MB
	QldE92thPxKrlsD/kn9T+E8vsdp9Z7OKnPt+iXJmm9++pwqntSrKalz4b6SbhVc4PpBz7F2/1Un
	TVdYxp6/w7Nww3SEG7jy+bUYjRztqLA4++8hxhgWpUTZx9DyLhcFjDlLtq+mvpSkUHTB98QREEi
	o+VQaHd3iD012dRr5OHDg4nDz1ESYaatq0cyHdZdTTLjAGBcACqv3n/FFDGtc2VL7QSgsOMRzeH
	n
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr17414303pgh.164.1549887937202;
        Mon, 11 Feb 2019 04:25:37 -0800 (PST)
X-Received: by 2002:a63:fd0a:: with SMTP id d10mr17414229pgh.164.1549887936077;
        Mon, 11 Feb 2019 04:25:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549887936; cv=none;
        d=google.com; s=arc-20160816;
        b=Y/BfjAfhy5QUIpG8nJPMV+sSUxS7x3aBcpxnMpz0m4GhhX+n2c1rfEYJik06httpb8
         RKPrm5IjUjn42nR7JXaLwwJiIct6sYYx95f2LctOYrEcYewDLe8Q10s0cYNzTd8oCgtj
         OD3QpDlnsbKt5Y5r/jI4G4THwR6r6jmUjjPD9G4jMCQaMx72Kn30h/WYVXNKYhv3iXDX
         szMSGWubulxg7WsuiGmtKDnoWLhf8Y/6jDVzvEC6A5iQ7LURNXYB6YEgohGeCbjQ+nRF
         Z83/2H/R79Hwh6Fg3J4tWt5snZlNr8EBxDpIXD1GAWwJeFiCMcLLZPuwfk9Nps52Bd/r
         e5cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=sCyib29/TDyxQaimgzlPTWBxPHLjbGAY4DKzfFTRAWk=;
        b=QpTfCKkz3op8TBa009d2L0S2FOvD6aZTSwCe9U9zpY6VIfRvrtUeJilgMccunlEu1M
         9x6Q7bosMmjU0Hm4RQ2379YppCrFjp77j0HQIbcdKuSQSZCC6qGIXMnu/+X1vo9P1jjt
         g7Vv+fLiyQ9lW9R39GIi+udZWLv1FzoWhNyyn/hYzNqcNq/3/8pUYDp8aywTPhlEywC2
         rqRDMmecjLL/k/fECJme9X25lRDWWj8StPYkY7NAxyHSCIKbHLOa1T2SYrUBs/r4dZzu
         QSsEBim5qgVu50YBaLZajkv7w92NIMsVHenfbSWAuWUhotHslYxmLH0H4GrNI+C2xOmd
         WSJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZzSiAq60;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e39sor13768510plb.21.2019.02.11.04.25.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 04:25:36 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZzSiAq60;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=sCyib29/TDyxQaimgzlPTWBxPHLjbGAY4DKzfFTRAWk=;
        b=ZzSiAq60GOu8fxBrqqllxVRdjUj/yTiH33wVnm+ESLsvpz2IauCgZFduqLex/dYQhy
         9JhEL5Z0cOO1Jn8J/ucUgpB3bUTWJJgf9JWzQmPOMd8aSOQY28UoDESz0CKyqXtpexR7
         FP7B7kWc1H8NNo3XHODNpAVIVXCeDDqzQCEig5O+Zwm/EK95NTyByfQUrU8Z7AwCBaBx
         NjLtuG2BOrjxkxyzi9TUnCOI51DhX9YIXE1Q1UhXtyGm+fTQmJvLg5uVO6CqZ7eyUuVB
         3tvc8X2HyvOpmV7jbFAYNSdVXDjFjmCWalg5f5d7IewSCrSz/xLMsp8tWqkQDa1t8m/d
         9VRQ==
X-Google-Smtp-Source: AHgI3IafbaWIVIfXyO8jrDe376WblbEqEBC/kZg7g+kVGlOk/gdYOd4YBVPGCvm5ZtXHEkF7rgW6Hpx4eq+iCvZdimo=
X-Received: by 2002:a17:902:1122:: with SMTP id d31mr37182411pla.246.1549887935379;
 Mon, 11 Feb 2019 04:25:35 -0800 (PST)
MIME-Version: 1.0
References: <cover.1548166824.git.christophe.leroy@c-s.fr> <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
 <87ef8i45km.fsf@dja-thinkpad.axtens.net> <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr>
 <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com> <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr>
In-Reply-To: <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 11 Feb 2019 13:25:24 +0100
Message-ID: <CAAeHK+zop5ajOJQ4KEYbuxMRegk2GM1LvuGcSbCU1O5EZxB0MA@mail.gmail.com>
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
To: christophe leroy <christophe.leroy@c-s.fr>
Cc: Daniel Axtens <dja@axtens.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, 
	Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, 
	kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 9, 2019 at 12:55 PM christophe leroy
<christophe.leroy@c-s.fr> wrote:
>
> Hi Andrey,
>
> Le 08/02/2019 =C3=A0 18:40, Andrey Konovalov a =C3=A9crit :
> > On Fri, Feb 8, 2019 at 6:17 PM Christophe Leroy <christophe.leroy@c-s.f=
r> wrote:
> >>
> >> Hi Daniel,
> >>
> >> Le 08/02/2019 =C3=A0 17:18, Daniel Axtens a =C3=A9crit :
> >>> Hi Christophe,
> >>>
> >>> I've been attempting to port this to 64-bit Book3e nohash (e6500),
> >>> although I think I've ended up with an approach more similar to Anees=
h's
> >>> much earlier (2015) series for book3s.
> >>>
> >>> Part of this is just due to the changes between 32 and 64 bits - we n=
eed
> >>> to hack around the discontiguous mappings - but one thing that I'm
> >>> particularly puzzled by is what the kasan_early_init is supposed to d=
o.
> >>
> >> It should be a problem as my patch uses a 'for_each_memblock(memory,
> >> reg)' loop.
> >>
> >>>
> >>>> +void __init kasan_early_init(void)
> >>>> +{
> >>>> +    unsigned long addr =3D KASAN_SHADOW_START;
> >>>> +    unsigned long end =3D KASAN_SHADOW_END;
> >>>> +    unsigned long next;
> >>>> +    pmd_t *pmd =3D pmd_offset(pud_offset(pgd_offset_k(addr), addr),=
 addr);
> >>>> +    int i;
> >>>> +    phys_addr_t pa =3D __pa(kasan_early_shadow_page);
> >>>> +
> >>>> +    BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
> >>>> +
> >>>> +    if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
> >>>> +            panic("KASAN not supported with Hash MMU\n");
> >>>> +
> >>>> +    for (i =3D 0; i < PTRS_PER_PTE; i++)
> >>>> +            __set_pte_at(&init_mm, (unsigned long)kasan_early_shado=
w_page,
> >>>> +                         kasan_early_shadow_pte + i,
> >>>> +                         pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
> >>>> +
> >>>> +    do {
> >>>> +            next =3D pgd_addr_end(addr, end);
> >>>> +            pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_p=
te);
> >>>> +    } while (pmd++, addr =3D next, addr !=3D end);
> >>>> +}
> >>>
> >>> As far as I can tell it's mapping the early shadow page, read-only, o=
ver
> >>> the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the ea=
rly
> >>> shadow PTE array from the generic code.
> >>>
> >>> I haven't been able to find an answer to why this is in the docs, so =
I
> >>> was wondering if you or anyone else could explain the early part of
> >>> kasan init a bit better.
> >>
> >> See https://www.kernel.org/doc/html/latest/dev-tools/kasan.html for an
> >> explanation of the shadow.
> >>
> >> When shadow is 0, it means the memory area is entirely accessible.
> >>
> >> It is necessary to setup a shadow area as soon as possible because all
> >> data accesses check the shadow area, from the begining (except for a f=
ew
> >> files where sanitizing has been disabled in Makefiles).
> >>
> >> Until the real shadow area is set, all access are granted thanks to th=
e
> >> zero shadow area beeing for of zeros.
> >
> > Not entirely correct. kasan_early_init() indeed maps the whole shadow
> > memory range to the same kasan_early_shadow_page. However as kernel
> > loads and memory gets allocated this shadow page gets rewritten with
> > non-zero values by different KASAN allocator hooks. Since these values
> > come from completely different parts of the kernel, but all land on
> > the same page, kasan_early_shadow_page's content can be considered
> > garbage. When KASAN checks memory accesses for validity it detects
> > these garbage shadow values, but doesn't print any reports, as the
> > reporting routine bails out on the current->kasan_depth check (which
> > has the value of 1 initially). Only after kasan_init() completes, when
> > the proper shadow memory is mapped, current->kasan_depth gets set to 0
> > and we start reporting bad accesses.
>
> That's surprising, because in the early phase I map the shadow area
> read-only, so I do not expect it to get modified unless RO protection is
> failing for some reason.

Actually it might be that the allocator hooks don't modify shadow at
this point, as the allocator is not yet initialized. However stack
should be getting poisoned and unpoisoned from the very start. But the
generic statement that early shadow gets dirtied should be correct.
Might it be that you don't use stack instrumentation?

>
> Next week I'll add a test in early_init() to check the content of the
> early shadow area.
>
> Christophe
>
> >
> >>
> >> I mainly used ARM arch as an exemple when I implemented KASAN for ppc3=
2.
> >>
> >>>
> >>> At the moment, I don't do any early init, and like Aneesh's series fo=
r
> >>> book3s, I end up needing a special flag to disable kasan until after
> >>> kasan_init. Also, as with Balbir's seris for Radix, some tests didn't
> >>> fire, although my missing tests are a superset of his. I suspect the
> >>> early init has something to do with these...?
> >>
> >> I think you should really focus on establishing a zero shadow area as
> >> early as possible instead of trying to ack the core parts of KASAN.
> >>
> >>>
> >>> (I'm happy to collate answers into a patch to the docs, btw!)
> >>
> >> We can also have the discussion going via
> >> https://github.com/linuxppc/issues/issues/106
> >>
> >>>
> >>> In the long term I hope to revive Aneesh's and Balbir's series for ha=
sh
> >>> and radix as well.
> >>
> >> Great.
> >>
> >> Christophe
> >>
> >>>
> >>> Regards,
> >>> Daniel
> >>>
> >>>> +
> >>>> +static void __init kasan_init_region(struct memblock_region *reg)
> >>>> +{
> >>>> +    void *start =3D __va(reg->base);
> >>>> +    void *end =3D __va(reg->base + reg->size);
> >>>> +    unsigned long k_start, k_end, k_cur, k_next;
> >>>> +    pmd_t *pmd;
> >>>> +
> >>>> +    if (start >=3D end)
> >>>> +            return;
> >>>> +
> >>>> +    k_start =3D (unsigned long)kasan_mem_to_shadow(start);
> >>>> +    k_end =3D (unsigned long)kasan_mem_to_shadow(end);
> >>>> +    pmd =3D pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), =
k_start);
> >>>> +
> >>>> +    for (k_cur =3D k_start; k_cur !=3D k_end; k_cur =3D k_next, pmd=
++) {
> >>>> +            k_next =3D pgd_addr_end(k_cur, k_end);
> >>>> +            if ((void *)pmd_page_vaddr(*pmd) =3D=3D kasan_early_sha=
dow_pte) {
> >>>> +                    pte_t *new =3D pte_alloc_one_kernel(&init_mm);
> >>>> +
> >>>> +                    if (!new)
> >>>> +                            panic("kasan: pte_alloc_one_kernel() fa=
iled");
> >>>> +                    memcpy(new, kasan_early_shadow_pte, PTE_TABLE_S=
IZE);
> >>>> +                    pmd_populate_kernel(&init_mm, pmd, new);
> >>>> +            }
> >>>> +    };
> >>>> +
> >>>> +    for (k_cur =3D k_start; k_cur < k_end; k_cur +=3D PAGE_SIZE) {
> >>>> +            void *va =3D memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> >>>> +            pte_t pte =3D pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
> >>>> +
> >>>> +            if (!va)
> >>>> +                    panic("kasan: memblock_alloc() failed");
> >>>> +            pmd =3D pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cu=
r), k_cur);
> >>>> +            pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(p=
te));
> >>>> +    }
> >>>> +    flush_tlb_kernel_range(k_start, k_end);
> >>>> +}
> >>>> +
> >>>> +void __init kasan_init(void)
> >>>> +{
> >>>> +    struct memblock_region *reg;
> >>>> +
> >>>> +    for_each_memblock(memory, reg)
> >>>> +            kasan_init_region(reg);
> >>>> +
> >>>> +    kasan_init_tags();
> >>>> +
> >>>> +    /* At this point kasan is fully initialized. Enable error messa=
ges */
> >>>> +    init_task.kasan_depth =3D 0;
> >>>> +    pr_info("KASAN init done\n");
> >>>> +}
> >>>> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> >>>> index 33cc6f676fa6..ae7db88b72d6 100644
> >>>> --- a/arch/powerpc/mm/mem.c
> >>>> +++ b/arch/powerpc/mm/mem.c
> >>>> @@ -369,6 +369,10 @@ void __init mem_init(void)
> >>>>       pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
> >>>>               PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
> >>>>    #endif /* CONFIG_HIGHMEM */
> >>>> +#ifdef CONFIG_KASAN
> >>>> +    pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
> >>>> +            KASAN_SHADOW_START, KASAN_SHADOW_END);
> >>>> +#endif
> >>>>    #ifdef CONFIG_NOT_COHERENT_CACHE
> >>>>       pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
> >>>>               IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
> >>>> --
> >>>> 2.13.3
> >>
> >> --
> >> You received this message because you are subscribed to the Google Gro=
ups "kasan-dev" group.
> >> To unsubscribe from this group and stop receiving emails from it, send=
 an email to kasan-dev+unsubscribe@googlegroups.com.
> >> To post to this group, send email to kasan-dev@googlegroups.com.
> >> To view this discussion on the web visit https://groups.google.com/d/m=
sgid/kasan-dev/69720148-fd19-0810-5a1d-96c45e2ec00c%40c-s.fr.
> >> For more options, visit https://groups.google.com/d/optout.
>
> ---
> L'absence de virus dans ce courrier =C3=A9lectronique a =C3=A9t=C3=A9 v=
=C3=A9rifi=C3=A9e par le logiciel antivirus Avast.
> https://www.avast.com/antivirus
>


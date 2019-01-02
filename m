Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C4EDC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 06:48:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A5D02089F
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 06:48:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WarTCNY0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A5D02089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BEDF8E000E; Wed,  2 Jan 2019 01:48:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 848008E0002; Wed,  2 Jan 2019 01:48:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E93B8E000E; Wed,  2 Jan 2019 01:48:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 11F5F8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 01:48:08 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f31so31210347edf.17
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 22:48:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iLoKSSytsM+0SiOlGYwk8zox7JBE2gbCmO+/LdxPZBI=;
        b=TrSjGMBMplY/vCjnfrx+xMg8YE/VA6Xfv0ket5ywxVwAN1L9iLtUS5TKfjshiMpt2P
         bLBjx4nAXT/Z99id+ECtCqOluqcS0AbTmnEmQ0fFnjjJQL8yzKG8+Ep4pLVfgy7rqkKY
         XkZCpKaPFZ12k337kukPE3ozaNs5+TLDudKig/nC+UGyckRIKTbeRy3c5CQ/lA4oWIJf
         bynJuV/81CgOuEu0rcZMiX5rPofYP3IkO5w4jF8GvKiklfOsT4SKSFlsClz0tt+cwyQZ
         U4t29Qp+2rKo2f5kri2/uXO5d77TiqB5nxYK0HU+7jYaa+IHVnfBgwOn2uSle3+BLLpI
         Y8gg==
X-Gm-Message-State: AA+aEWaVY5nzsZy5Z7joyU6ERgmdbD2OK6lj1E8nS2niwurMFPfNrvOX
	Nc+eWBQrjXR/ocqQpJOwb9zhTjfck7ijyz/Ac+2avB38C/HWd0xGLib59z32ZmToeVzhIQmMsLE
	9M5O1jXUtlWpK6f9BfOA7XQnEmZ5w+97gEy5ncLYOOwSC+evlRgyu3XZhxCQ1pIBzIeT0YkOSX/
	7lE4w128w70o+GwvjWG7Hw5a4HOrU/OKyRXAH3M0vGkNjdWgwXQnFLBVadLaHpR4gDncaKUe5AQ
	CeJD8MV64b4d8RCaYEJVdGe105bSQdhbL/WLeb7V06DUf7OGDLo5L0tKmpctQT71ruw4d2yomdJ
	xaIBJFF+ZmTVg03urWNJRgUjTttHF6i5j4qbk1M/RBS5xbKkZp+iFB7RNhqRoi/AiskqeRicOSk
	u
X-Received: by 2002:a17:906:5e46:: with SMTP id b6-v6mr32348525eju.44.1546411687588;
        Tue, 01 Jan 2019 22:48:07 -0800 (PST)
X-Received: by 2002:a17:906:5e46:: with SMTP id b6-v6mr32348502eju.44.1546411686535;
        Tue, 01 Jan 2019 22:48:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546411686; cv=none;
        d=google.com; s=arc-20160816;
        b=ZB6OMjk5uK76LPj9fuXLWXMQs/kzRuS1rPm9Z8yZB9kKFTfaVpl2iywcp2SO+CfnlC
         BTt7oO/MRyn7j8qH82Dk/8FS/aXIwkzDo7jZhfYhlZmTAXWmuReDgZyvppBWd8sv9lWm
         IemjvQt+pPqdLCg1j68ams4MHKhzLCXBchndI4k4qPtH2RGGQb0kVPjOrl/aRG4KMKMv
         aGDT0lyS13MZlwZRFRMC0R+ZnV+ehwR3I9EgznQL3CwfRwB7TYpWUCKCe4hr0l8QxlBX
         +8+dGHN1wX2Zlt7w4I1GpuwEBFgRt2/7+oN9WbSmfbcZ0sAjCFEMhZX07QjJr4ETUW1E
         irhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iLoKSSytsM+0SiOlGYwk8zox7JBE2gbCmO+/LdxPZBI=;
        b=fXyGm4iUTs1ad8gRCmaJ3RalR9kvAOtx+G3y9VHpP0TUkJFoUc+Oif3/Kyn543Wn8/
         0ow9Q/ps032Ib79JP98rlF9nqM8APIiBFgC95wsT/NGsSQ48Cc2R8qfj4GblnAu/kbyr
         2UkXgpxWY8Ng4K27Rgm61otgGSkDe5WxaiDxDEb/Qwert3gl1MZJED1bfh/OuKv8xilr
         OkmEsz5v628ofD0HyYh2YIQKF9ZOcUmhM+ZQCXSt56PNvtzJ3SZ7ozEAIZ/s4fx/VxNj
         p3Qs3FG35ts8N0NEECfqbEjUbQ/xieu1V5rqInFInLqsqvk4oZdpw/ROayeSmcQtofE7
         h2Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WarTCNY0;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor14073795edx.3.2019.01.01.22.48.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 22:48:06 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WarTCNY0;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iLoKSSytsM+0SiOlGYwk8zox7JBE2gbCmO+/LdxPZBI=;
        b=WarTCNY0I1tvz/qfiEaFAMuW+gSYZLk/IB53c0yaTzJ6jqdJ5cDigPe2rx+E3zJWej
         xWJAlhg8wViBTYoWvz5CLfTKR+FvObPsG1SbSSCgxO3s94JCasx9zKnHNE3p+f4j+deZ
         zgnRk4loGqKbwUtFwsqGAKPWi5isaNByOGX3L5gwhDhH24M0HRjFeT7MgsPLFvKKmrtZ
         8CH17sugvG0a1a2v0EtlXPWI3BALSRshQ/kg6pv9viDPF/UIi/BH8LfKs57nLez+vrIg
         9BVGnZ/Akj780RwJ3lqkwBLLg09KMRLsmxK4+IGynwT9fX5UF68WUcKXrzR7Nu7TU2oj
         TV/g==
X-Google-Smtp-Source: AFSGD/XZXAXwAjiL4nyx4K9YlpP4K/naYkkbRAKn9Prliikb0aoPOKwano0REdSuS6B+xVBAmgE/eSsWFPh37hKtNpg=
X-Received: by 2002:a50:9feb:: with SMTP id c98mr38053176edf.253.1546411686136;
 Tue, 01 Jan 2019 22:48:06 -0800 (PST)
MIME-Version: 1.0
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
 <1545966002-3075-3-git-send-email-kernelfans@gmail.com> <20181231084608.GB28478@rapoport-lnx>
In-Reply-To: <20181231084608.GB28478@rapoport-lnx>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 2 Jan 2019 14:47:54 +0800
Message-ID:
 <CAFgQCTs2A-_ZzLAz=wZng=2e3+VURd97wJxLv5UesVUTMaw0hg@mail.gmail.com>
Subject: Re: [PATCHv3 2/2] x86/kdump: bugfix, make the behavior of
 crashkernel=X consistent with kaslr
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, 
	Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, 
	Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
	Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, 
	Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, yinghai@kernel.org, 
	vgoyal@redhat.com, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102064754.SvcXupRKcun4UzssPE9LF-BKrQAO6mYQgTTc-z9c9es@z>

On Mon, Dec 31, 2018 at 4:46 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Fri, Dec 28, 2018 at 11:00:02AM +0800, Pingfan Liu wrote:
> > Customer reported a bug on a high end server with many pcie devices, where
> > kernel bootup with crashkernel=384M, and kaslr is enabled. Even
> > though we still see much memory under 896 MB, the finding still failed
> > intermittently. Because currently we can only find region under 896 MB,
> > if w/0 ',high' specified. Then KASLR breaks 896 MB into several parts
> > randomly, and crashkernel reservation need be aligned to 128 MB, that's
> > why failure is found. It raises confusion to the end user that sometimes
> > crashkernel=X works while sometimes fails.
> > If want to make it succeed, customer can change kernel option to
> > "crashkernel=384M, high". Just this give "crashkernel=xx@yy" a very
> > limited space to behave even though its grammer looks more generic.
> > And we can't answer questions raised from customer that confidently:
> > 1) why it doesn't succeed to reserve 896 MB;
> > 2) what's wrong with memory region under 4G;
> > 3) why I have to add ',high', I only require 384 MB, not 3840 MB.
> >
> > This patch simplifies the method suggested in the mail [1]. It just goes
> > bottom-up to find a candidate region for crashkernel. The bottom-up may be
> > better compatible with the old reservation style, i.e. still want to get
> > memory region from 896 MB firstly, then [896 MB, 4G], finally above 4G.
> >
> > There is one trivial thing about the compatibility with old kexec-tools:
> > if the reserved region is above 896M, then old tool will fail to load
> > bzImage. But without this patch, the old tool also fail since there is no
> > memory below 896M can be reserved for crashkernel.
> >
> > [1]: http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
> > Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> > Cc: Tang Chen <tangchen@cn.fujitsu.com>
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Len Brown <lenb@kernel.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Jonathan Corbet <corbet@lwn.net>
> > Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
> > Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> > Cc: Nicholas Piggin <npiggin@gmail.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Daniel Vacek <neelx@redhat.com>
> > Cc: Mathieu Malaterre <malat@debian.org>
> > Cc: Stefan Agner <stefan@agner.ch>
> > Cc: Dave Young <dyoung@redhat.com>
> > Cc: Baoquan He <bhe@redhat.com>
> > Cc: yinghai@kernel.org,
> > Cc: vgoyal@redhat.com
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  arch/x86/kernel/setup.c | 9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> >
> > diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> > index d494b9b..165f9c3 100644
> > --- a/arch/x86/kernel/setup.c
> > +++ b/arch/x86/kernel/setup.c
> > @@ -541,15 +541,18 @@ static void __init reserve_crashkernel(void)
> >
> >       /* 0 means: find the address automatically */
> >       if (crash_base <= 0) {
> > +             bool bottom_up = memblock_bottom_up();
> > +
> > +             memblock_set_bottom_up(true);
> >
> >               /*
> >                * Set CRASH_ADDR_LOW_MAX upper bound for crash memory,
> >                * as old kexec-tools loads bzImage below that, unless
> >                * "crashkernel=size[KMG],high" is specified.
> >                */
> >               crash_base = memblock_find_in_range(CRASH_ALIGN,
> > -                                                 high ? CRASH_ADDR_HIGH_MAX
> > -                                                      : CRASH_ADDR_LOW_MAX,
> > -                                                 crash_size, CRASH_ALIGN);
> > +                     (max_pfn * PAGE_SIZE), crash_size, CRASH_ALIGN);
> > +             memblock_set_bottom_up(bottom_up);
>
> Using bottom-up does not guarantee that the allocation won't fall into a
> removable memory, it only makes it highly probable.
>
> I think that the 'max_pfn * PAGE_SIZE' limit should be replaced with the
> end of the non-removable memory node.
>
Since passing MEMBLOCK_NONE, memblock_find_in_range() ->...->
__next_mem_range(), there is a logic to guarantee hotmovable memory
will not be stamped over.
if (movable_node_is_enabled() && memblock_is_hotpluggable(m))
continue;

Thanks,
Pingfan

> > +
> >               if (!crash_base) {
> >                       pr_info("crashkernel reservation failed - No suitable area found.\n");
> >                       return;
> > --
> > 2.7.4
> >
>
> --
> Sincerely yours,
> Mike.
>


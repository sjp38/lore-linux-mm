Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58FE1C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B8DD204FD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:37:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N6diFwKa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B8DD204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A849E6B000D; Fri, 17 May 2019 09:37:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0E266B000E; Fri, 17 May 2019 09:37:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88A1C6B0010; Fri, 17 May 2019 09:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4BA6B000D
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:37:27 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id c2so1451598vsm.9
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=rALcOjDg9E/vrRFZ56/P2LXxAPmUukWJQy4a30LDzVw=;
        b=rT7bneheGaDS3gG/d/Km+e+x0OJMBLPE5cYwHL01/yyttVwDoZsBnWJb+aJHS2lrsr
         3aFwYIjV2b2VxGhKfMoMAYZv9jD7cc04mxQXwggOMt702xb3RIsNEWtVt4YicY2VQZBJ
         Y/vy1kr8essigQG6TC23hesPtP5jqKQnbnzK7kiOK/lnwL89pHOfzT5DdNSvUNCpXlwR
         Tm+kb5f5/HNbyqPAQj5gaj+ggVy3nYnlRD40DmFIWtiyWguVlpkAr937URFyd6fn+rWN
         fwDwSuInfMoZk3QwWYQIdz3tVKQlQDsWH1u7PEasozJu8a+DShpsVq0151RZ19SSI/u4
         uQbA==
X-Gm-Message-State: APjAAAW8vz45msT8o3u64Wr+v0YQG/ECCDhIDAx9mpKvP40YWGEd5k0e
	sLBCdU1nWeZgGz77GKmlaiHru3MtCBeM2aozsVFvGW6/ZrEVo8oqY9vUpjVqJbgbR/2PzNSECHw
	+JTAVLrnEnLXvU51kEF7SxhdqVc1atGmLqges5ncAAw2GJpRt3SufJIOhE1EcIFe/XA==
X-Received: by 2002:a1f:8407:: with SMTP id g7mr2292992vkd.27.1558100247084;
        Fri, 17 May 2019 06:37:27 -0700 (PDT)
X-Received: by 2002:a1f:8407:: with SMTP id g7mr2292952vkd.27.1558100246314;
        Fri, 17 May 2019 06:37:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558100246; cv=none;
        d=google.com; s=arc-20160816;
        b=wn/htoQgVfNHE6mlFMe3Aai/iLokcEfX3oOygEjO4rK2q4j91CHzl1wX+JXywH3/RV
         AdDJurhoYv8WrjSubji1N2h7Tg/Q9KIX19Q4/KsEuAu0PdqrOvVkh4BdmqKsc5R4hSCy
         UVRfyb7o2ewBNCP7I+1gi1bhBNxsQHyT6mJpkNfIvuXeXxJ98JCl7597qqsuynskgRlh
         6FGqlV12o0tYsezaFR8KP9fp7tAfyvT2hvfm0YUKniPuPwiMDS0qMXW4/miGMQD9jL5F
         VJ/HoEncTG8WgHCkM45iHF6hCjxmNlAsThPdmLL+KHU76EMDpvEFO9pYyoz/lf8v2Pku
         55IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=rALcOjDg9E/vrRFZ56/P2LXxAPmUukWJQy4a30LDzVw=;
        b=eSmHidN0qm84Yr8IVW7zqnm5ijN65j2m2y5aNWMx0wvhqCur61hT/lh9LgDzZ5jSZa
         8XJ3+ko7tyJiARyLqIVSLSDa7fKE79YADu4CUiXSyaLtDU0RPXewlA8T5/EMKDvdff8L
         n8VX3kYQZVNJNndM3CIL9cVjbENFAUZ0fqCrMOOfuGK/DclAwO3WlREj/rlBAQ/ooTQY
         uZqEm+rnpfJCHEXrpBC4torG2OqlEwSktb125Fj/nj6TRtzctuxYK8JpuDLifZpU4kuM
         SdaDy1zNw5EdpzMLZMjLIkJclzRkUzffl1285wuKzanaC9gaeeRPIefgRJMLaaQC59SG
         8BCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N6diFwKa;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6sor4274342vsp.61.2019.05.17.06.37.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 06:37:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N6diFwKa;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=rALcOjDg9E/vrRFZ56/P2LXxAPmUukWJQy4a30LDzVw=;
        b=N6diFwKae7Xebdp8VESEcBkBun/aShV8RfDsJJzw0N3A3jzlLXOb3XBhO6mAOUsT59
         Zr7UBXgpDEglLYAEkepavmSrNK4/SjBZx+Kge/y3j2eATHsoQzIP/baC5o+OfVeb/IQB
         mm8jblbcSBIQKiyu07Ra0/124JavXFWAa347T7iWhAiJaNlwWxg7bznsyOprorRVIee2
         Wlg8rroFnil0VSkUFMPZ18apd9es55qmZv0sFNRkvnrWzX7b77KHKQBi9S3qY0UnVBKy
         Cs9vico4ZRDuSzrMR0Dg9JwXwQSPgHqJUF4TULfhZg7rJoj3w026heEwYH3WQo4Tt5K+
         Dflg==
X-Google-Smtp-Source: APXvYqxToGqnElKC9nWr8GbUih64IA8GrKNZKvxD/ri1bLLFKcz6TFqspjE/LhuI/gbnQOxKKHdmiu7b7vkpypPhhQM=
X-Received: by 2002:a67:6801:: with SMTP id d1mr28125826vsc.209.1558100245663;
 Fri, 17 May 2019 06:37:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz> <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
 <20190517132542.GJ6836@dhcp22.suse.cz>
In-Reply-To: <20190517132542.GJ6836@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 15:37:14 +0200
Message-ID: <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Matthew Wilcox <willy@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 3:25 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 17-05-19 15:18:19, Alexander Potapenko wrote:
> > On Fri, May 17, 2019 at 2:59 PM Michal this flag Hocko
> > <mhocko@kernel.org> wrote:
> > >
> > > [It would be great to keep people involved in the previous version in=
 the
> > > CC list]
> > Yes, I've been trying to keep everyone in the loop, but your email
> > fell through the cracks.
> > Sorry about that.
>
> No problem
>
> > > On Tue 14-05-19 16:35:36, Alexander Potapenko wrote:
> > > > When passed to an allocator (either pagealloc or SL[AOU]B),
> > > > __GFP_NO_AUTOINIT tells it to not initialize the requested memory i=
f the
> > > > init_on_alloc boot option is enabled. This can be useful in the cas=
es
> > > > newly allocated memory is going to be initialized by the caller rig=
ht
> > > > away.
> > > >
> > > > __GFP_NO_AUTOINIT doesn't affect init_on_free behavior, except for =
SLOB,
> > > > where init_on_free implies init_on_alloc.
> > > >
> > > > __GFP_NO_AUTOINIT basically defeats the hardening against informati=
on
> > > > leaks provided by init_on_alloc, so one should use it with caution.
> > > >
> > > > This patch also adds __GFP_NO_AUTOINIT to alloc_pages() calls in SL=
[AOU]B.
> > > > Doing so is safe, because the heap allocators initialize the pages =
they
> > > > receive before passing memory to the callers.
> > >
> > > I still do not like the idea of a new gfp flag as explained in the
> > > previous email. People will simply use it incorectly or arbitrarily.
> > > We have that juicy experience from the past.
> >
> > Just to preserve some context, here's the previous email:
> > https://patchwork.kernel.org/patch/10907595/
> > (plus the patch removing GFP_TEMPORARY for the curious ones:
> > https://lwn.net/Articles/729145/)
>
> Not only. GFP_REPEAT being another one and probably others I cannot
> remember from the top of my head.
>
> > > Freeing a memory is an opt-in feature and the slab allocator can alre=
ady
> > > tell many (with constructor or GFP_ZERO) do not need it.
> > Sorry, I didn't understand this piece. Could you please elaborate?
>
> The allocator can assume that caches with a constructor will initialize
> the object so additional zeroying is not needed. GFP_ZERO should be self
> explanatory.
Ah, I see. We already do that, see the want_init_on_alloc()
implementation here: https://patchwork.kernel.org/patch/10943087/
> > > So can we go without this gfp thing and see whether somebody actually
> > > finds a performance problem with the feature enabled and think about
> > > what can we do about it rather than add this maint. nightmare from th=
e
> > > very beginning?
> >
> > There were two reasons to introduce this flag initially.
> > The first was double initialization of pages allocated for SLUB.
>
> Could you elaborate please?
When the kernel allocates an object from SLUB, and SLUB happens to be
short on free pages, it requests some from the page allocator.
Those pages are initialized by the page allocator and split into
objects. Finally SLUB initializes one of the available objects and
returns it back to the kernel.
Therefore the object is initialized twice for the first time (when it
comes directly from the page allocator).
This cost is however amortized by SLUB reusing the object after it's been f=
reed.

> > However the benchmark results provided in this and the previous patch
> > don't show any noticeable difference - most certainly because the cost
> > of initializing the page is amortized.
>
> > The second one was to fine-tune hackbench, for which the slowdown
> > drops by a factor of 2.
> > But optimizing a mitigation for certain benchmarks is a questionable
> > measure, so maybe we could really go without it.
>
> Agreed. Over optimization based on an artificial workloads tend to be
> dubious IMHO.
>
> --
> Michal Hocko
> SUSE Labs



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg


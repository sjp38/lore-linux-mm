Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B5A5C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:18:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D4EF2166E
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:18:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CZjfeqpw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D4EF2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8F456B000A; Fri, 17 May 2019 09:18:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C17566B000C; Fri, 17 May 2019 09:18:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92A46B0010; Fri, 17 May 2019 09:18:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80DC96B000A
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:18:32 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id k71so2511356vka.18
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:18:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=PHV0x8tuOxPE6AqNKxBxzAvruYWCBsuwR0QrG4TEbUE=;
        b=qPwotpiuzfAt0DbI9risDN2N0dAigakpod5/JusSxwgUtbrOcEhD6ZWHOMCgXFqbZM
         /eIcHxQuyku0GxfkKZ9J3IJDAxR+NKHNF++M1kDhuA3VimK8yBj9FXtILv2K8OtQ1fvb
         tYkYLi3ESfgUQ8BZCk40Kaz9Gk58v/okAlgMChrBVSC2SabloJOCaU/MdGCGfdOfvmGS
         WrW+ozvyVHN37EyVfqDmYt0HXgQuOJr7auYtkfpcXYCC/Ax5pAjqOkUeI/jqOfq4zeIu
         1Kws/62op8mvWsZA+m5kID/d+m4taW3pqW68n59NhdJWT5pjsCN22waxz5+Qyfmn9G3i
         +nSw==
X-Gm-Message-State: APjAAAUgR0nb53ig7Besej9Cxo6Cm7rTbFMOMXr+sI1Besl2s3USUyAC
	rTfvrrFPH/g9zCjO7YOA8866iL13wOq1VLyhWaIQBI1fyIFrLpfR/e6yDuEY+ABSfMiHnFWYEI7
	SU87ty3R6tsA0emLHJy2JCMzjEYVu+gdkMtiaA0s/WhBfv3SSgO234oyZZb+aiWgmyg==
X-Received: by 2002:a67:8988:: with SMTP id l130mr25878308vsd.137.1558099112201;
        Fri, 17 May 2019 06:18:32 -0700 (PDT)
X-Received: by 2002:a67:8988:: with SMTP id l130mr25878281vsd.137.1558099111595;
        Fri, 17 May 2019 06:18:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558099111; cv=none;
        d=google.com; s=arc-20160816;
        b=MPdakArSQK29vCf1riftYrOudIcUwPahj7ZGlqqt3wXu60Pf9SOesHZP52KhA/5B+j
         v4BxGyZ65AqfYGR4sVoGRRJSz3sUgBD/cPpzFaf1WK2RZQmm8MPhTbs2ZVOY57clI6Qc
         MX52NQ7rTS1O9Kx9mYsJ7ys200EctFvix7NspHQmLoH10TjvFjlT6DkckfsDLpYQm+WJ
         Lpd/a7o/LaUszZgBjAnPNVDjr3d36CXR5zhxnqLjluT3jD1d24sbUXa8dDHwDoyPx3ZW
         WfSyO1i6UE96cUJ8QxMTUQuhqU7o725y7eF5IP6PuVIOu277ICtPsUm2F+dstQA2UZic
         1tzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=PHV0x8tuOxPE6AqNKxBxzAvruYWCBsuwR0QrG4TEbUE=;
        b=frqZlKvCINjlhbCYftNabFaVnFXDxTQmxG8CbSQSvlb1D3AH+aKfAf4lz0TynOYVpB
         d/7LhvllV7s1p4Bftm5oV/xZN0TB5fe22HjFurXWhqiR9oyq6CIvPSSIBYMxyg+ejxph
         Ml/5Po4LhqYaMqbv7E+BVQt/1QPkB4RpZqGG6HlDFg4ryt/NAzJWEW4TrvTE0H7rDOeB
         9GyfvqrtQk0KR0na7SCiDr8hB8Q4cN+Sik4hF4t54UzlD3Bfv0BwOA09Gzm6pj/bUqUw
         Vh8ii1z++EriFpXdoMOGbZRMR0QzWkCD2MI/JEO7IBpbJlTeWHpThgzEkblaQiVY/1DS
         OuYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CZjfeqpw;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 184sor2637477vkw.41.2019.05.17.06.18.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 06:18:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CZjfeqpw;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=PHV0x8tuOxPE6AqNKxBxzAvruYWCBsuwR0QrG4TEbUE=;
        b=CZjfeqpw5FcEeYHMcUKZVX8/pa/LEJC0l7EOx5UoHipHih2W8VGdJ8TVRwU2TuCvhw
         /5gNk4X5G3s2uLTIq4aB82fNENnK4Pvncv2CsRtPemDSOyF62oJQwWU1NEJfZ5Kw3z9q
         5U3fAlo4NnuNYAs9dqqmxBZq5aSMFSkgwz42a1MX33oHOnJhz65SEPPXfhcsNLonGjBo
         m/n2xS5DaD5mRefwlNU6XgweWmVdAU4JZCEECBVWqP2lBkxN6Zxo29p1pasfElCWCAI7
         UNjsW2knxCfX4SsRQ9yb6Qgy0Wv16iC3hx54Kjs9q4umf79mYey1ShkyEqq/f+EKL3iz
         sGqA==
X-Google-Smtp-Source: APXvYqyKBU4Hrndly6ZORHu6XZo6dCOdhGOvLEa/j2LUVcs0Hwr5DRL/F/5P3O7jDiSyGYHh0UJe3x4EkQIEynAhKpU=
X-Received: by 2002:a1f:3492:: with SMTP id b140mr2372879vka.8.1558099111004;
 Fri, 17 May 2019 06:18:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz>
In-Reply-To: <20190517125916.GF1825@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 15:18:19 +0200
Message-ID: <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
To: Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
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

On Fri, May 17, 2019 at 2:59 PM Michal this flag Hocko
<mhocko@kernel.org> wrote:
>
> [It would be great to keep people involved in the previous version in the
> CC list]
Yes, I've been trying to keep everyone in the loop, but your email
fell through the cracks.
Sorry about that.
> On Tue 14-05-19 16:35:36, Alexander Potapenko wrote:
> > When passed to an allocator (either pagealloc or SL[AOU]B),
> > __GFP_NO_AUTOINIT tells it to not initialize the requested memory if th=
e
> > init_on_alloc boot option is enabled. This can be useful in the cases
> > newly allocated memory is going to be initialized by the caller right
> > away.
> >
> > __GFP_NO_AUTOINIT doesn't affect init_on_free behavior, except for SLOB=
,
> > where init_on_free implies init_on_alloc.
> >
> > __GFP_NO_AUTOINIT basically defeats the hardening against information
> > leaks provided by init_on_alloc, so one should use it with caution.
> >
> > This patch also adds __GFP_NO_AUTOINIT to alloc_pages() calls in SL[AOU=
]B.
> > Doing so is safe, because the heap allocators initialize the pages they
> > receive before passing memory to the callers.
>
> I still do not like the idea of a new gfp flag as explained in the
> previous email. People will simply use it incorectly or arbitrarily.
> We have that juicy experience from the past.

Just to preserve some context, here's the previous email:
https://patchwork.kernel.org/patch/10907595/
(plus the patch removing GFP_TEMPORARY for the curious ones:
https://lwn.net/Articles/729145/)

> Freeing a memory is an opt-in feature and the slab allocator can already
> tell many (with constructor or GFP_ZERO) do not need it.
Sorry, I didn't understand this piece. Could you please elaborate?

> So can we go without this gfp thing and see whether somebody actually
> finds a performance problem with the feature enabled and think about
> what can we do about it rather than add this maint. nightmare from the
> very beginning?

There were two reasons to introduce this flag initially.
The first was double initialization of pages allocated for SLUB.
However the benchmark results provided in this and the previous patch
don't show any noticeable difference - most certainly because the cost
of initializing the page is amortized.
The second one was to fine-tune hackbench, for which the slowdown
drops by a factor of 2.
But optimizing a mitigation for certain benchmarks is a questionable
measure, so maybe we could really go without it.

Kees, what do you think?
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


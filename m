Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1CE8C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:22:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E0E420868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 12:22:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JBRSf+Ji"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E0E420868
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3988A6B0003; Tue, 16 Apr 2019 08:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 347BD6B0006; Tue, 16 Apr 2019 08:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 238206B0007; Tue, 16 Apr 2019 08:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 015F96B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:22:12 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id j193so4060431vsd.2
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 05:22:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=bdEs7uYsw1GOSiu24cA7C0KHfg2lyObuKuQzd3OIlyk=;
        b=V3uNOGnShyO17wHOcSXJmLa4XzH+yBJ6xMrSjfppdGR+ltoCyEg/hfIdQu1FsZDlgq
         srPpHQlPeQbMMfts8D8RDDlTwGl4OG7y9k4t8tsnFkyx1NzgntgiZmxaK8eKpJ/wFSfd
         PifAlPj8s/hBDrf5P87n71S+rhtMP2Xj98DIC28Mdk5NnAXhBqPfBGSqHUumXX7BWOjX
         /nmiZMuMP3lEJh7XGJ6nmm+SwyJXPM1SqYrt+gvdWXZFydxWm5jDKu5PoiKjuX8obwHh
         xxnwvKRzkEymKy/D9BsiVp0De5pgs4065IqvC++l5ly7vYr4Dm785Oa8TbCRLk5aF9md
         JDug==
X-Gm-Message-State: APjAAAUzpJyavEP1EC48PbouTu2phQgM0PLYOnEBj79QSHWjtVfu4ANo
	afLWmanbqTlxlrtoeAL06ZYOl5JHzJ1k25ZY0cBJkfBnoKz2XBrzE7hdfIyl45ZAjdIoAZy3PIO
	NFRv60NXDPU8nG824O2rzsFFi3NgTXwqcWmRF+4hw+sGrO8cBfoMFWxoFWixQoGGgGg==
X-Received: by 2002:ab0:6193:: with SMTP id h19mr42502501uan.47.1555417331650;
        Tue, 16 Apr 2019 05:22:11 -0700 (PDT)
X-Received: by 2002:ab0:6193:: with SMTP id h19mr42502461uan.47.1555417330974;
        Tue, 16 Apr 2019 05:22:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555417330; cv=none;
        d=google.com; s=arc-20160816;
        b=M6S8GRFwb2YTlnUq6g937NOuBaeP1JY8I/+pY1jXQgBgVolIDCtVvfpHqoJT4IuDT7
         3+hiyddjbbL4LiinfO8FkzVPI/5iuQdTxHOJ+w6SfoUQvb6OhcJCV285RpjBOE99KQR6
         7arM3DdiS5IcbuP8dTXBpSK4C2rs9D8kxjNlY+Ssix0sJzwsHzmw5boHjvbPt/FV6tIS
         ze/jzUHXW5SRucnjhccutH91k0vMYd/NHT0RAi6DgRw+uDwqKHBvK31aGj932o6i2i87
         e8oJ3brJqt2o0Wbjh6oquzRT3tvYAd6ZnG2CT+KcWUjq1sNB0A5uijRV1JfL2ey8Cgs8
         Rkpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=bdEs7uYsw1GOSiu24cA7C0KHfg2lyObuKuQzd3OIlyk=;
        b=JTRJMHeMm0G2JKvSVUF2lpqr0T96X/C2NNoZfrmSu3Tf9QNwCnjyScPY1OtkeGE4L0
         SvUfoCVmMdKne8/kE76UBanJO3yd2+JD7aX0Ykg7BHZiJUdC5qngJx5q3V3ebgnT5AyP
         0yazjH7NU1KeItZQNdA0tedzX+ord0X7KzIK3vDjBaA6IXRHf7sbDjILEgs+e6jDM6J0
         JqfTFJIb2FnS1xENK2bxLnaYf/cz53vwrC1FSZpkf/uXdMrHtA2bhOX5UEZjr1gPO2od
         n8TeDyYBqs8YPhBBoJH3kD9CROs3uj4jEBFyAtA4C0B+IqpsbJAbul+fQ7xEHV47ofSW
         oDdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JBRSf+Ji;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor17535091uaf.9.2019.04.16.05.22.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 05:22:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JBRSf+Ji;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=bdEs7uYsw1GOSiu24cA7C0KHfg2lyObuKuQzd3OIlyk=;
        b=JBRSf+Ji0s54jJi+6Lpqy370y89sX7kIKPg+sfBOKk/mLimssDnGKH9zXMjCE89lG8
         IR9sjMMTs0rwQvkaDLSe+ZlHEyt04Ur3x6it1Aap2kZbQTwEF/NGXRkpdGM8Ee5TyTSC
         V8JPndQF+f3TsfWTcvRmz4nrDY21rpmgij5TXJC4858ZL+uPIbOHFERn9EFJhHg7INSK
         +Jj0taGaG4Xcjde402fKSp89nZ1FQT2lWuZsGMBDQid4apwhl8SZZ/7UNsmS2CwSufrn
         umDsHypZ4yKWxONLl1Bie35QqbmJhGecQXHhxKRAviEKuDaJOyJhNZSMb70zy3F1evwS
         w/YA==
X-Google-Smtp-Source: APXvYqyVe76DswO88r/webO5iCtniBizYS3WbdFa5kvuIF7qLTsDqkoZD1+jZ+BupMeU3+8JZRVAi/HGBcaW150CI1U=
X-Received: by 2002:ab0:2495:: with SMTP id i21mr41234515uan.49.1555417330235;
 Tue, 16 Apr 2019 05:22:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190412124501.132678-1-glider@google.com> <20190415190213.5831bbc17e5073690713b001@linux-foundation.org>
In-Reply-To: <20190415190213.5831bbc17e5073690713b001@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 16 Apr 2019 14:21:59 +0200
Message-ID: <CAG_fn=W1rELLO4mx1RoM01shFVkyQjT3eU5wyqMRjprzVD5oMQ@mail.gmail.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-security-module <linux-security-module@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Sandeep Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 4:02 AM Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> On Fri, 12 Apr 2019 14:45:01 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
> > This config option adds the possibility to initialize newly allocated
> > pages and heap objects with zeroes.
>
> At what cost?  Some performance test results would help this along.
I'll make more measurements for the new implementation, but the
preliminary results are:
~0.17% sys time slowdown (~0% wall time slowdown) on hackbench (1 CPU);
1.3% sys time slowdown (0.2% wall time slowdown) when building Linux with -=
j12;
4% sys time slowdown (2.6% wall time slowdown) on af_inet_loopback benchmar=
k;
up to 100% slowdown on netperf (caused by sk buffers being initialized
multiple times; also netperf is too fast to perform any precise
measurements)

Are there any benchmarks you can recommend?
> > This is needed to prevent possible
> > information leaks and make the control-flow bugs that depend on
> > uninitialized values more deterministic.
> >
> > Initialization is done at allocation time at the places where checks fo=
r
> > __GFP_ZERO are performed. We don't initialize slab caches with
> > constructors or SLAB_TYPESAFE_BY_RCU to preserve their semantics.
> >
> > For kernel testing purposes filling allocations with a nonzero pattern
> > would be more suitable, but may require platform-specific code. To have
> > a simple baseline we've decided to start with zero-initialization.
> >
> > No performance optimizations are done at the moment to reduce double
> > initialization of memory regions.
>
> Requiring a kernel rebuild is rather user-hostile.
This is intended to be used together with other hardening measures,
like CONFIG_INIT_STACK_ALL (see a patchset by Kees).
All of those require a kernel rebuild, but we assume users don't push
and pull that lever back and forth often.

> A boot option
> (early_param()) would be much more useful and I expect that the loss in
> coverage would be small and acceptable?  Could possibly use the
> static_branch infrastructure.
I'll try that out and see if there's a notable performance difference.

> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -167,6 +167,16 @@ static inline slab_flags_t kmem_cache_flags(unsign=
ed int object_size,
> >                             SLAB_TEMPORARY | \
> >                             SLAB_ACCOUNT)
> >
> > +/*
> > + * Do we need to initialize this allocation?
> > + * Always true for __GFP_ZERO, CONFIG_INIT_HEAP_ALL enforces initializ=
ation
> > + * of caches without constructors and RCU.
> > + */
> > +#define SLAB_WANT_INIT(cache, gfp_flags) \
> > +     ((GFP_INIT_ALWAYS_ON && !(cache)->ctor && \
> > +       !((cache)->flags & SLAB_TYPESAFE_BY_RCU)) || \
> > +      (gfp_flags & __GFP_ZERO))
>
> Is there any reason why this *must* be implemented as a macro?  If not,
> it should be written in C please.
Agreed. Even in the case we want GFP_INIT_ALWAYS_ON to be known at
compile time there's no reason for this to be a macro.
>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg


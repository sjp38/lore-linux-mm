Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 202E3C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 09:48:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE2EF20827
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 09:48:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="u1svwCOk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE2EF20827
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66CFD8E0069; Tue,  8 Jan 2019 04:48:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F7528E0038; Tue,  8 Jan 2019 04:48:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C0E78E0069; Tue,  8 Jan 2019 04:48:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2288E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:48:30 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id j123so1442327vsd.9
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:48:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=SdWSdZKQoBjiJH/4qdCEMKqURCxYsoxn1mik+e6P1ng=;
        b=i/8B69O/4NI7grMQWfsLk6kAgF309s8Sjd+uKssA5G8XFStUdcs7xuXOTy3ojopyn+
         GWwWEp72t7NYYpzs2RwOWsxksGfDPVQvx1IZpPnHmKhG69WFN1UsZu9Hn58iVOmNf8sy
         GKIEb28ZTcm1LHoPrQE1lJOPNJ+pH+bpdpcR/sFtUJGW8Ffd4syT0mR9A257Mw7pVm/X
         STvjLo/irhIP8TQLuUcvTzJu3kr3puDitbzFtTuFr3fD9lNQ/nFyPp48upfvA3bqtl3M
         9a9QSkLTOGXKElH+8lDbShEO4RzoAIyD7ADM4NFOFvEvT3VEXXNS1uLEF+a+4HRJTIOW
         9KdQ==
X-Gm-Message-State: AJcUukfTtCOAO0sqOUXftu16h/Uxc0oxrGDAT0/BJOdXpHAm7Ajl2S/6
	Q/XURM1PSj1V3ZEqEZ6jDHcAmONlsdvO4EjgQBk09wKPRVHYNAFO83tDEqEaeQ5cUgse9Tne6b0
	AaXIDwhP87Yu8RzsU8fTuV+zdy9cTq9HWjM2DFIYn1YZNfVYmb90Wqk6yR/wvwdd4j6Nz3983bc
	sspW4zS0Seg4t+2UsYD0Cw5Duvh3MWLvZBIGohiSrxAeJaiEpAXObv5/hC3eG96zDtzuMQiUrMk
	uWo4ivd+gocgcxR2/aGYlFVoW3FLCAeZClUDSoiK0RgXeAOU+wCplW/W7DY7yqcMsn9kOqw2yKD
	EyaNBf2k7IhCJT0pU15U6r2yHXsHlvLJToQtg2ODRkUkCM3y/bLQR1ZR4v6xTI+FxeeluD+S0Y0
	W
X-Received: by 2002:a1f:9c81:: with SMTP id f123mr332950vke.85.1546940909661;
        Tue, 08 Jan 2019 01:48:29 -0800 (PST)
X-Received: by 2002:a1f:9c81:: with SMTP id f123mr332942vke.85.1546940909010;
        Tue, 08 Jan 2019 01:48:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546940908; cv=none;
        d=google.com; s=arc-20160816;
        b=NnMBYj7HOeqNSV1HbWErHqn8J4KEM2elgntCFn/yu3voI5Ooaj9rXBvKUg2CSajBrc
         oL5PmQBMTBWXdi154cBDQDG9RShMuYQSFT0y5RS2//fslj4ISt2vWLP75O1WjB0LTdH+
         ayUALoPOrzTwT8ZAslMEQvYOW7lAJ4clUAla5AoHub1EvUdZdTLCe3IRihskdgOUgNAE
         aFtVXGW7a8iVy9vr8Kzg1OY4dBpTgLsF26BWA9WbcaebOthrYxrzVf2/prg4V0yKw98z
         +d1WORXOzlxMjQc+XE/6YJ+ngBSRyLBM+k8ZUao+VGKAy9F50tbwMHg/DMNgltYyzRQh
         n8Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=SdWSdZKQoBjiJH/4qdCEMKqURCxYsoxn1mik+e6P1ng=;
        b=b60PoMEgYvbsHgYO2/uMBv7EI2KzO7ctl//zq8xfXFyaaMgnFHmt5D95bFfbrG1kHj
         LI1ydhX9y3Y/qy4eTMhSXOYqgEYaqWD9BOTMDv4d5foRjHbZ9InzXnKBDOz/BO48ppUv
         QzjsfHjqNc7fIMLCH09p9F1pmZQ8ekK+wnsC6e+irSe0rawiIGTQ0fhsARiU6UrXFzGE
         quS0UIuLvf0J4qPg/E75phTH5KQSdtAcZUGAoNvBHCCdigzZCCvPqNsQhE0ECU1XbW91
         NdpE7etblzB+FaaGVLLt4le7k2nlPNeVr7nMabPGaH9oQtdDL6gRRb6+PvWYoV1gRnZz
         ctCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=u1svwCOk;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p63sor44789028vsd.106.2019.01.08.01.48.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 01:48:28 -0800 (PST)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=u1svwCOk;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=SdWSdZKQoBjiJH/4qdCEMKqURCxYsoxn1mik+e6P1ng=;
        b=u1svwCOknjtO2VZ27q6q1v7Pd/20qqElikNPB2VDJzD9fMhgtVfqcN2uyQZkJAeZX/
         CC3SbHgNN8fM7ZVsGDv0yIelf2ZPiOUANQLs1IZI2cY75+qvXPhr57vrN4XzKtsXjqsH
         9a206lNdPH3stl30LiSbuCjPrfPVLWI6T4XQVqZrIzGoCSNgpqaBLTg1LYQZI7PfofOg
         v9NDnvYaptxb7ZXQ/q69eUEH4baHxwo1A1dGAP1jJjpMgnh84gcL9Yb3Zz9frAxcnZ6O
         OQrqXyBP62h1I0R880aRhnFoDKEIJKokblCcXEdaQvJTvxbrQbXa6kNNdsHeo0wuQp8J
         gG1w==
X-Google-Smtp-Source: ALg8bN78fAngS7rKFMWTyCgk4TKLIsvZdZarRTfd1W4iYXkn9CbLZCGQ+7J90sy608fubAs+b8cNB9wJ2alYbq5P4BA=
X-Received: by 2002:a67:88c9:: with SMTP id k192mr416911vsd.103.1546940908443;
 Tue, 08 Jan 2019 01:48:28 -0800 (PST)
MIME-Version: 1.0
References: <20181211133453.2835077-1-arnd@arndb.de> <20190108022659.GA13470@flashbox>
 <CACT4Y+a_LB6aVoLEcFVJhP40D9E4MM3T=7-0aBhFvBffXgNZmw@mail.gmail.com>
In-Reply-To: <CACT4Y+a_LB6aVoLEcFVJhP40D9E4MM3T=7-0aBhFvBffXgNZmw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 8 Jan 2019 10:48:17 +0100
Message-ID:
 <CAG_fn=XQsZ5AHj2f10_xmOzb3PUeQgT52-0XLD-W6kAb8xx0sg@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
To: Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Anders Roxell <anders.roxell@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Nathan Chancellor <natechancellor@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108094817.72GaJ9_dwjWYrWWFN_SqgVOywu5GMERljVy84WO2Op0@z>

On Tue, Jan 8, 2019 at 5:51 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>
> On Tue, Jan 8, 2019 at 3:27 AM Nathan Chancellor
> <natechancellor@gmail.com> wrote:
> >
> > On Tue, Dec 11, 2018 at 02:34:35PM +0100, Arnd Bergmann wrote:
> > > Building little-endian allmodconfig kernels on arm64 started failing
> > > with the generated atomic.h implementation, since we now try to call
> > > kasan helpers from the EFI stub:
> > >
> > > aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: i=
n function `atomic_set':
> > > include/generated/atomic-instrumented.h:44: undefined reference to `_=
_efistub_kasan_check_write'
> > >
> > > I suspect that we get similar problems in other files that explicitly
> > > disable KASAN for some reason but call atomic_t based helper function=
s.
> > >
> > > We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
> > > that the compiler sets instead of checking CONFIG_KASAN, but this in =
turn
> > > requires a small hack in mm/kasan/common.c so we do see the extern
> > > declaration there instead of the inline function.
> > >
> > > Fixes: b1864b828644 ("locking/atomics: build atomic headers as requir=
ed")
> > > Reported-by: Anders Roxell <anders.roxell@linaro.org>
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Alexander Potapenko <glider@google.com>
> > > ---
> > >  include/linux/kasan-checks.h | 2 +-
> > >  mm/kasan/common.c            | 2 ++
> > >  2 files changed, 3 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-check=
s.h
> > > index d314150658a4..a61dc075e2ce 100644
> > > --- a/include/linux/kasan-checks.h
> > > +++ b/include/linux/kasan-checks.h
> > > @@ -2,7 +2,7 @@
> > >  #ifndef _LINUX_KASAN_CHECKS_H
> > >  #define _LINUX_KASAN_CHECKS_H
> > >
> > > -#ifdef CONFIG_KASAN
> > > +#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
> > >  void kasan_check_read(const volatile void *p, unsigned int size);
> > >  void kasan_check_write(const volatile void *p, unsigned int size);
> > >  #else
> > > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > > index 03d5d1374ca7..51a7932c33a3 100644
> > > --- a/mm/kasan/common.c
> > > +++ b/mm/kasan/common.c
> > > @@ -14,6 +14,8 @@
> > >   *
> > >   */
> > >
> > > +#define __KASAN_INTERNAL
> > > +
> > >  #include <linux/export.h>
> > >  #include <linux/interrupt.h>
> > >  #include <linux/init.h>
> > > --
> > > 2.20.0
> > >
> >
> > Hi all,
> >
> > Was there any other movement on this patch? I am noticing this fail as
> > well and I have applied this patch in the meantime; it would be nice fo=
r
> > it to be merged so I could drop it from my stack.
>
> Alexander, ping, you wanted to double-check re KMSAN asm
> instrumentation and then decide on a common approach for KASAN and
> KMSAN.

I like Arnd's approach and will do the same for KMSAN.
Arnd, please go ahead submitting your patch.
The only possible issue I'm anticipating is that in the future we may
want to disable the checks in non-KASAN code (e.g. in arch/ or mm/),
so __KASAN_INTERNAL may not be the best name, but that's up to you.

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg


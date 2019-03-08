Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDA96C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:03:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55CE820675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:03:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c//MCzmW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55CE820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB28C8E0003; Thu,  7 Mar 2019 22:03:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B38CC8E0002; Thu,  7 Mar 2019 22:03:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D8678E0003; Thu,  7 Mar 2019 22:03:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 279798E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:03:46 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id f69so2624499lfg.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:03:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XOdoGoPqsBrpNR+sr6f/M0KLXQUMtWTZm9TpBp/xnVE=;
        b=pmUIBbvEBB4pclxj/4tpGCrRLvVu4/lwvM1a6bOlySrG900uQ8IXd8x+wBuubO2fME
         Qix9wIV6LaogSQOydGw6LlN2M0Zv/vpO2/J9BVGOdCpXlMqMyPD9GV8UrrBjqiVpEwuv
         4U/3XbA3iDNKRhNgffgmWun+yVh2JoHP+nChSqk4U+mXF1+9VpjcaD5KbI9N+kfB/x4Q
         kwrpV5fyc5TPFNTRswXNvV73UBDuB3PxoboZDw3w66WQfeFE6xPP9ZcKSv/KOzr8pe1V
         HdGA0YX0xpk6a8Zp47Bkejze43hj420msHjHfRHn//hgYnKpdTLG2Ab3deki5PK/Ij/H
         uzgg==
X-Gm-Message-State: APjAAAV/ZyOSMi+zgmkWuKxCFNZW2Iv+EPm2R6djPJ7zMXUJTC0GMNuo
	wP9SMSfpIWBbTvxuBhQdseywS4syv4zF6LHYbq2KTEtcwmw1crBT11TOLWu1uqNRBf+6Cz0nRIs
	QjKEBlHNlpcJnyAi60YxjArSPRgkX4v5tI1BUInaZkyvPpnIvNLl4TWTwBT2YlroSyh8pz3prXE
	wlmeVarw+F2Z0KMEzqHSjoMxazv1VNJBr0WYBzi7pI8HOiJR37TKmb8uy05iMNCL7UpuEwNqKCW
	wJyZMGLktqzSvQ5SOL7JBFUbHjZt9lKbrR7x+sRCuh1wgxrfd4jbv7AAdKBM87IiHkWWa/yHvF6
	VFd8S0219YuWJm+cNFJ9IVgoXTkqbzAaGp+dCCw2keM1ZigMUh8GbfeIQqvH/9txxvNSiRtG4Ys
	J
X-Received: by 2002:a2e:968c:: with SMTP id q12mr7707075lji.95.1552014225191;
        Thu, 07 Mar 2019 19:03:45 -0800 (PST)
X-Received: by 2002:a2e:968c:: with SMTP id q12mr7707049lji.95.1552014224353;
        Thu, 07 Mar 2019 19:03:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552014224; cv=none;
        d=google.com; s=arc-20160816;
        b=TA1OxQYq9cjgG6Y8wDSa01GJNxISSS7q99qMI43F8l+DXPwptXQ4LtbQNUm5l+64IU
         ifv2hXgAFQFo2Mbs5E/2ehNt1ZbcqLP0AVoiMcHDXi9SjZxBARPvjLGU2Q/by4H8Dvve
         dDCOUVUCTo6Vgt3ku2FOFhQBQWGAPEQihGFgEm/M/+D9rFNbB4sGLnsj7+4msV6p62Dt
         y9K76M6oPzHnz9pdhW4deCb91tcwYLI1rWyzcM6GW30dBCywfESrQwe+8WawPZMxdXY9
         nWvO71DEirwcDlsgdY5CBBnHl72H1TfJ2zNUhWxZd/B2bdcR2NRY08K0IsmPZcQX1ZvL
         kxOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XOdoGoPqsBrpNR+sr6f/M0KLXQUMtWTZm9TpBp/xnVE=;
        b=q7CsZ2T6RflkQhXmzNQDzMTwk4WcMt0Ux1Cs/McCs+CkAYDnI6svcPQIVg84aHnPVR
         y+M+/1wR2l8S/27s/BWYMrovh11HYEqTHmHOFSZT1i97Vl+Qlv7sviauzMNf+P2/VxZG
         XNNNBzn7KZOVIEPMk59A+IBF9CAIc0BsD3rplgL9Q54O65E3SL7LOShWwGrWvm0t0m6v
         L1Nw8gaTbJlsGWRJBo4gqX+FvmuLsByDreinms7qU8vALDS5CHzTznML1COeo688Pbai
         RUABfi//ILKUg5rXmhXN0DmCHi/qchZ6Z0XzY6++EpCLpEj1WoURDa8Wss4IwmWe4dKt
         JBDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="c//MCzmW";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8sor4787272ljk.12.2019.03.07.19.03.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 19:03:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="c//MCzmW";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XOdoGoPqsBrpNR+sr6f/M0KLXQUMtWTZm9TpBp/xnVE=;
        b=c//MCzmWZjEMLa/ETbqKv4K5xOSGukyK1EuO0WPQRdOpZ19Elf6Dl1xbq1RjyPgOOs
         KQFkVDGyamEx4nam/ZOSAzD9ebRTOBLrrIvLwzXLq0nloCneuCoAsljmbHQMOE6jKACV
         rLEhjEFKbflhXSgqCCtcXv2/2ovenW69yG83AThl+FlrGfgw5DPab6dqmPe/qTz+2ncV
         S/TuawnXt+S5i+N2A72lQL7I9hDy2E8ZVAnixb7jNGSJWKmvkzrdtxDPdgUPtcd4uL6Y
         u6e4YJARy6xWa5MpFaJ5KMlyBT8tspQ6mZqv8WQXkJq0MyT4Oh+ATJR3MEislHBB3+j8
         9u3Q==
X-Google-Smtp-Source: APXvYqycao6IfUCpZdvTe04mJcr2kYiysV/ShktNMCsh8kRWFdG5H0a6c7txy6GZcZBkV093G0x1VyJK6H9MxlP5dVs=
X-Received: by 2002:a2e:8886:: with SMTP id k6mr8258223lji.43.1552014223831;
 Thu, 07 Mar 2019 19:03:43 -0800 (PST)
MIME-Version: 1.0
References: <1fa6fadf644859e8a6a8ecce258444b49be8c7ee.1551716733.git.andreyknvl@google.com>
 <67536e1d-2819-553d-521c-bae21a51e0f7@virtuozzo.com>
In-Reply-To: <67536e1d-2819-553d-521c-bae21a51e0f7@virtuozzo.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 8 Mar 2019 08:33:31 +0530
Message-ID: <CAFqt6zY387LVbo3sxBvDDvKMb+41KcLcmN-W+ncPJbrUm5STaw@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix coccinelle warnings in kasan_p*_table
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, Kostya Serebryany <kcc@google.com>, 
	kbuild test robot <lkp@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 5, 2019 at 9:43 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
>
> On 3/4/19 8:04 PM, Andrey Konovalov wrote:
> > kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
> > returning bool, but return 0 instead of false, which produces a coccinelle
> > warning. Fix it.
> >
> > Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
> > Reported-by: kbuild test robot <lkp@intel.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
>
> Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>
>
> >  mm/kasan/init.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/kasan/init.c b/mm/kasan/init.c
> > index 45a1b5e38e1e..fcaa1ca03175 100644
> > --- a/mm/kasan/init.c
> > +++ b/mm/kasan/init.c
> > @@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
> >  #else
> >  static inline bool kasan_p4d_table(pgd_t pgd)
> >  {
> > -     return 0;
> > +     return false;
> >  }
> >  #endif
> >  #if CONFIG_PGTABLE_LEVELS > 3
> > @@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
> >  #else
> >  static inline bool kasan_pud_table(p4d_t p4d)
> >  {
> > -     return 0;
> > +     return false;
> >  }
> >  #endif
> >  #if CONFIG_PGTABLE_LEVELS > 2
> > @@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
> >  #else
> >  static inline bool kasan_pmd_table(pud_t pud)
> >  {
> > -     return 0;
> > +     return false;
> >  }
> >  #endif
> >  pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
> >
>

Acked-by: Souptick Joarder <jrdr.linux@gmail.com>


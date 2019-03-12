Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2999DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:04:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCD3A2087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=baylibre-com.20150623.gappssmtp.com header.i=@baylibre-com.20150623.gappssmtp.com header.b="xXGa1xhP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCD3A2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=baylibre.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 758718E0003; Tue, 12 Mar 2019 10:04:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 707F98E0002; Tue, 12 Mar 2019 10:04:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CFA58E0003; Tue, 12 Mar 2019 10:04:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADC98E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:04:05 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id u24so1172311otk.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:04:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=RC9n/L2urRzMIddaEkM47GUXLJfkJCfKnT+zLB1fxyQ=;
        b=IF6WM0IB1B1Nod6MVNQaZxLor9c8c+p8fEa+gw9bjy/oM88woASMabEyb/Hemsm35+
         n3gdKWlucRCfXgPSZOCRRQgC2Wb3VV3rkd5g97Zs2lg/a0cpLd4Y5WSCg+B3ux2pRx+t
         1XGUB3RkR4DRAU2CIWkf0RcNQU5Glm7y5tzihaSpTJbR3RWJyPg1wpRUWJtAkVSTI2ru
         r+j54l25wbj4Lnt/xzEn8PyCK5tiUU3XqsTmz7UK54z3zYLw1MzjZMrvbvrF5ClzBtcV
         DerwxxpmIGPKS2DZVQ/LpQNj5aqAf0kUUaA+OI66tvdphtJAly726h+KL6201PczvDLN
         k/Cw==
X-Gm-Message-State: APjAAAV1iH1AYc7MSBkgchCUEwszgvd/e6LK4KWqxE1b/AEv7DsBR31T
	u67am9oFoTjrndQaS1jV4w+lMT5GK6CXs22I6JU9V6L3qVpzsP5m93xZQrG5OAtrTaeDQBGe2iW
	PemWwV3BhruJdzzOMfXmDZpQWXK+ESRC9FhcbUUueD1LSSCSGVKAW7na1DH4Z8dg1CnZblU9nya
	ALdr/BwWZaiQrNYviZ6YyZTJMHqSf488qWS6HmhDW5UUEYaaloGjiyZnR3kxA5V5fN9B1uXAmQs
	CKEMmpQAvzXRLxcwvfxwfsy1V/rXLFBpWDnV/Z73A6Bcsl4O9TiSwqfIovt/oyEz6gHeFiJdz/7
	trbDF/K4Z/YzQSICLAkZVBo2MzgszuG3ayI3JVL7VVAxrwsa31R62yUmXEmLh5M4L8eRsqEpLZN
	N
X-Received: by 2002:aca:4b51:: with SMTP id y78mr1838251oia.88.1552399444720;
        Tue, 12 Mar 2019 07:04:04 -0700 (PDT)
X-Received: by 2002:aca:4b51:: with SMTP id y78mr1838199oia.88.1552399443899;
        Tue, 12 Mar 2019 07:04:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552399443; cv=none;
        d=google.com; s=arc-20160816;
        b=vF93NzgNBs71UeAp8BmUOdzouRQJn83a4uQKM+Epp9STk6kCWbzDxMnAvM5dyfohFI
         1DvSB9Sped2GdGzx7RzyZ3n+igH8A3BPssvcNK2dL+BBswcmGcyNOAk2Ity9bSOCUDbN
         7jkqVJjlikJUhog3ynAwBUmXp8KepCzVExmtTXnn4vyAFamK3QBDQ8mP7Y8yXlAb2VKy
         jpM3XRBhHkPlc7sJUWnxvszZs0MFKgTx75cd16qiz8VaPt+Svh4UzGUSmmPtcFVDIgcK
         AQCrXoAXDTu64WWJPD61AeAb39OVvKFBPJ3bYFmqgbMVq10+vYAbPgmW3BfXGuFa5KAy
         XMrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=RC9n/L2urRzMIddaEkM47GUXLJfkJCfKnT+zLB1fxyQ=;
        b=EPzjz2p3cSN1zMBnbA7aRIFg0ZLTgECu2xqkd+e3YO4jpwsWmxb26trEtrunlBI1Sj
         KKNUMmWM6vMPzPM2REIWRjuceiuPbh4h9Scq5hi+pIieDlfk1iuZ+Cp3lDJTN01tQyJh
         GqDd4gQhlhcS89RVcBcnLvH9r4e7Mzk8Vz7LwJzAqcw/a6W52tDg1O2OEWFk20hPW7B3
         pAV9ZsaIkbDgiCpGT44WClX85yTX9O2FhnWOYHmLJ6soNbQRido9ok+/wSVPopctB/CU
         BG968h/V23u7bqABdq+OI8kosgT1YeLrn7BGBwwg4m/lz9X98QT2k+NUdUZHWNgdqR+Y
         Gw8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@baylibre-com.20150623.gappssmtp.com header.s=20150623 header.b=xXGa1xhP;
       spf=pass (google.com: domain of bgolaszewski@baylibre.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bgolaszewski@baylibre.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f206sor4453724oia.151.2019.03.12.07.04.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 07:04:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of bgolaszewski@baylibre.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@baylibre-com.20150623.gappssmtp.com header.s=20150623 header.b=xXGa1xhP;
       spf=pass (google.com: domain of bgolaszewski@baylibre.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bgolaszewski@baylibre.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=baylibre-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=RC9n/L2urRzMIddaEkM47GUXLJfkJCfKnT+zLB1fxyQ=;
        b=xXGa1xhPq962PZh/0M3j4mAOlmZhS6NFDXzo4vogkbyqv8U/tAbx8VNHJd6v5gaJbq
         iGPH2tBC8fkPtNUdDfrARZkcdTs9pn6H7O9/hI80ITNHS0D1dz4jr2y2Fb+w3ZCGYfCE
         A4mGfJj1LXwVSWhi/LvnZ6mfPUrMgPy61gAjgvpnWxvleAq+h6HXaEMYRJxwZVWCmRmq
         CQ87C8MPJdouValtJ3f2b6kP2ucp6E2Oxmpv+N5ezPOzbEMBLqVYMG1ZZ6L944+2pORs
         UX9YOCdpXCFbej3zSL4snoaAfGWMegeigvwjUU+7ia/FQcyNWZr8FXPErpNcFtn4MuC0
         7C1w==
X-Google-Smtp-Source: APXvYqyO6Ri3cTvigCbe4KdbtZeEZKJtgtqAvWC8KsVCZmDNW8WB/VAD7yQrl9q0/Vf+C2xe+YiOvgpi4jzuwHVVbrk=
X-Received: by 2002:aca:4dca:: with SMTP id a193mr1806746oib.21.1552399443282;
 Tue, 12 Mar 2019 07:04:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190312132852.20115-1-brgl@bgdev.pl> <c86234af-a83a-712a-8dc8-0ec2a5dad103@oracle.com>
In-Reply-To: <c86234af-a83a-712a-8dc8-0ec2a5dad103@oracle.com>
From: Bartosz Golaszewski <bgolaszewski@baylibre.com>
Date: Tue, 12 Mar 2019 15:03:52 +0100
Message-ID: <CAMpxmJVeeMRPaXMKp29mE08pKFU4RRMetY=9-pWmazLg3DMLbg@mail.gmail.com>
Subject: Re: [PATCH] mm: remove unused variable
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Bartosz Golaszewski <brgl@bgdev.pl>, Andrew Morton <akpm@linux-foundation.org>, 
	Anthony Yznaga <anthony.yznaga@oracle.com>, 
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

wt., 12 mar 2019 o 14:59 Khalid Aziz <khalid.aziz@oracle.com> napisa=C5=82(=
a):
>
> On 3/12/19 7:28 AM, Bartosz Golaszewski wrote:
> > From: Bartosz Golaszewski <bgolaszewski@baylibre.com>
> >
> > The mm variable is set but unused. Remove it.
>
> It is used. Look further down for calls to set_pte_at().
>
> --
> Khalid
>
> >
> > Signed-off-by: Bartosz Golaszewski <bgolaszewski@baylibre.com>
> > ---
> >  mm/mprotect.c | 1 -
> >  1 file changed, 1 deletion(-)
> >
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 028c724dcb1a..130dac3ad04f 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_=
struct *vma, pmd_t *pmd,
> >               unsigned long addr, unsigned long end, pgprot_t newprot,
> >               int dirty_accountable, int prot_numa)
> >  {
> > -     struct mm_struct *mm =3D vma->vm_mm;
> >       pte_t *pte, oldpte;
> >       spinlock_t *ptl;
> >       unsigned long pages =3D 0;
> >
>
>

Oops, I blindly assumed the compiler is right, sorry for that. GCC
complains it's unused when building usermode linux. I guess it's a
matter of how set_pte_at() is defined for ARCH=3Dum. I'll take a second
look.

Bart


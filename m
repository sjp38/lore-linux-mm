Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B44F5C3A5A9
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 02:59:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CDCF20882
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 02:59:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="VqOYx8x1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CDCF20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5086B0003; Wed,  4 Sep 2019 22:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D74B66B0005; Wed,  4 Sep 2019 22:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C627E6B0006; Wed,  4 Sep 2019 22:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id A3E1D6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 22:59:57 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 409062C96
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:59:57 +0000 (UTC)
X-FDA: 75899362434.30.group14_39b7367aed930
X-HE-Tag: group14_39b7367aed930
X-Filterd-Recvd-Size: 5782
Received: from mail-oi1-f193.google.com (mail-oi1-f193.google.com [209.85.167.193])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 02:59:56 +0000 (UTC)
Received: by mail-oi1-f193.google.com with SMTP id g128so586975oib.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 19:59:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uuS19FigxfakDYnvbAFxrtuUuHeM+v/iuERCHWfI3vo=;
        b=VqOYx8x1bDNUzmv9Rw4i2vA/owzg0BIpRGl9KWN5ZYTQ27gaRH2CxrCzmKRr3NVWov
         XYbG3g9POX2CAkk4HAmEOmBN9Hzd6CuhdrYYitVBZ39DB9vDRPmoREMcmNR8aDKrHqXA
         OAlDFtTq5tyRApJRImhGhc7a8emPQqeTZJke00cVRZ2qgq96qJKSvIcJpuSELk/Q/AiR
         NW3hk5ytezFM+9nDWo0gxTCAA5p3PFpIVqVE4MAjXPPzp82Kitr/+w/0nVOeaH0LDAC/
         i6BBj+81jkeKNqObQIR5qou/n0lSoovua+2VT+Pzgvu05EIw79XEXXUXyWYXcTPWarTB
         tImQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=uuS19FigxfakDYnvbAFxrtuUuHeM+v/iuERCHWfI3vo=;
        b=l6TKoq7/Do1XE1olyUJmlsuagHusccoxbcxSIoMfX0PHlQECk/Pmhdgo64uHs7JUYf
         DtWqGh7bOOOjLcgwNJyp/MIrgcUMaN/fpHybdronYDgwref2lBbjdJjre1JVj1T3c+uR
         X5XCltIgLImseoJHdJM2nWdRgEB780Jw6yR86Qq4T3uL8f0EgIqjVsQEECbsegnIhH+r
         2wAQMgh/qiUdsIChtywlzURoOBMdU+JUMv1u4w+UIvZvskDAEE22WqVLQDwgq9SKptxp
         mMxpkeTxk7FYnGkLMc/DtkpvnHpmo88YiR5dUcybQn/duR1LaEm2N7Xco7Ad5FQZqd40
         vUsg==
X-Gm-Message-State: APjAAAXvLnhlltulVAukvHyxi/yo67lSvCbj2FaG35VNvHvHWmG7HHgD
	Kev+NQSQ8vMGxaqmmLUQ95xj6rFSbvB/4HQ9oEvOXQ==
X-Google-Smtp-Source: APXvYqyxamQwBtVbn3EMfEbVBXSL/c/+KSoAeh7HrSM0V3HubzqEYm/MZVDIH+yfZMW+BWDzv8S8C51R2d+6E2Dq2sw=
X-Received: by 2002:aca:62d7:: with SMTP id w206mr940739oib.0.1567652395683;
 Wed, 04 Sep 2019 19:59:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190904065320.6005-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hD8SAFNNAWBP9q55wdPf-HYTEjpS4m+rT0VPoGodZULw@mail.gmail.com> <33b377ac-86ea-b195-fd83-90c01df604cc@linux.ibm.com>
In-Reply-To: <33b377ac-86ea-b195-fd83-90c01df604cc@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 4 Sep 2019 19:59:43 -0700
Message-ID: <CAPcyv4hBHjrTSHRkwU8CQcXF4EHoz0rzu6L-U-QxRpWkPSAhUQ@mail.gmail.com>
Subject: Re: [PATCH v8] libnvdimm/dax: Pick the right alignment default when
 creating dax devices
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > Keep this 'static' there's no usage of this routine outside of pfn_devs.c
> >
> >>   {
> >> -       /*
> >> -        * This needs to be a non-static variable because the *_SIZE
> >> -        * macros aren't always constants.
> >> -        */
> >> -       const unsigned long supported_alignments[] = {
> >> -               PAGE_SIZE,
> >> -#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >> -               HPAGE_PMD_SIZE,
> >> +       static unsigned long supported_alignments[3];
> >
> > Why is marked static? It's being dynamically populated each invocation
> > so static is just wasting space in the .data section.
> >
>
> The return of that function is address and that would require me to use
> a global variable. I could add a check
>
> /* Check if initialized */
>   if (supported_alignment[1])
>         return supported_alignment;
>
> in the function to updating that array every time called.

Oh true, my mistake. I was thrown off by the constant
re-initialization. Another option is to pass in the storage since the
array needs to be populated at run time. Otherwise I would consider it
a layering violation for libnvdimm to assume that
has_transparent_hugepage() gives a constant result. I.e. put this

        unsigned long aligns[4] = { [0] = 0, };

...in align_store() and supported_alignments_show() then
nd_pfn_supported_alignments() does not need to worry about
zero-initializing the fields it does not set.

> >> +       supported_alignments[0] = PAGE_SIZE;
> >> +
> >> +       if (has_transparent_hugepage()) {
> >> +
> >> +               supported_alignments[1] = HPAGE_PMD_SIZE;
> >> +
> >>   #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> >> -               HPAGE_PUD_SIZE,
> >> -#endif
> >> +               supported_alignments[2] = HPAGE_PUD_SIZE;
> >>   #endif
> >
> > This ifdef could be hidden in by:
> >
> > if IS_ENABLED(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)
> >
> > ...or otherwise moving this to header file with something like
> > NVDIMM_PUD_SIZE that is optionally 0 or HPAGE_PUD_SIZE depending on
> > the config
>
>
> I can switch to if IS_ENABLED but i am not sure that make it any
> different in the current code. So I will keep it same?

It at least follows the general guidance to keep #ifdef out of .c files.

>
> NVDIMM_PUD_SIZE is an indirection I find confusing.
>

Ok.

> >
> > Ok, this is better, but I think it can be clarified further.
> >
> > "For dax vmas, try to always use hugepage mappings. If the kernel does
> > not support hugepages, fsdax mappings will fallback to PAGE_SIZE
> > mappings, and device-dax namespaces, that try to guarantee a given
> > mapping size, will fail to enable."
> >
> > The last sentence about PAGE_SIZE namespaces is not relevant to
> > __transparent_hugepage_enabled(), it's an internal implementation
> > detail of the device-dax driver.
> >
>
> I will use the above update.
>

Thanks.


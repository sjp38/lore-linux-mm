Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0AA8C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:18:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 617282147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:18:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 617282147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA6348E0004; Tue, 12 Mar 2019 17:18:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54F98E0002; Tue, 12 Mar 2019 17:18:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6C738E0004; Tue, 12 Mar 2019 17:18:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 793308E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:18:57 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d5so4496190pfo.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:18:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gfoR90FAE2ZTfWcvfu5Iel8TnOC4RF7tWdZ/YYSxCO0=;
        b=VqOGYTENGqO6axRKtnJl+vJvJcueIfvUf32vXR8zaTEv425NQTDnb6bWq1MBx3pJSF
         76uMwfSBPWFfqGkAZ3rCCKhLyYHbuUL1rz8eUYO709292OHh5WdMtSJFwA5dea33+McI
         lrgz1hTLG6doR/AT3AD7J6FWTmsDF9yQS/FgCvxU1pHBcCiDc4W9GdcM/KhEY64CiD/J
         5PkH7pOBx00OvZ63J202oupBufZqUkp5Ar1sED97ytjH9uwjbKWAfSLEp4ye2yVdgUzv
         81yUgslz2Jf0HJ6OONtt2X7G24WzVKtjL96OmNVZujr0FcY88misFbnr7eGFT6kAR1n/
         5nhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUrMKMqsUi6n3XTCz71ucNiS/hTtFioakoSqV2hu1VRGIwLrnCW
	Xg9J8LDZRo5+Qhm9os0iztzwJQqvZ09Wvq+3YJiWxP/ISC1Gluu1EXuv7OnuKBZt91YJHcnbCoZ
	wfkunojKGwXnXeWdZ7s3FtmUfzNSLTTfTOCEUEG3fCWqRNVWKrEUlxbaozSCTnMoLVQ==
X-Received: by 2002:a65:510c:: with SMTP id f12mr37594087pgq.40.1552425536963;
        Tue, 12 Mar 2019 14:18:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw2sW/P8e2MqOT/ACO6m2LpT+rSaDy7Marpvqc0Yv0W0i0rhY9LLmNkvbCOdsVq4pTat6t
X-Received: by 2002:a65:510c:: with SMTP id f12mr37594022pgq.40.1552425535979;
        Tue, 12 Mar 2019 14:18:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552425535; cv=none;
        d=google.com; s=arc-20160816;
        b=zR2qXJ58+hFXcGmqf7ijb1QeV5bJ9uR9qdgoGGIgqw6Ip3g7dIp2PLH+rwHT8qjhim
         +b9JExT/su6A20rNRFDCKbqUWAvnNDW/DnpIT9gfHGsrPEDQeR9eCyioPeRO6oQaZa98
         J/OmbzgHNAA2A5Cdbcix7/xn1tOSLaW4SNo80oyd/u0WGIQuv9QDw5grEnJZ6mhYPM1l
         CudvalJwsW2ONmzGMpqCy58sU6WFhLzJhTiY1uHTKCw1nlWFDdFgH10CHgz9cDmh1v3q
         xvRiJf9jK9eRyleTw61w3gMWVb603DJpUT7vDbpPa6pXuJwmWQDcrHfG588Twsygi8Aq
         66Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=gfoR90FAE2ZTfWcvfu5Iel8TnOC4RF7tWdZ/YYSxCO0=;
        b=GtkvcqkRde+hvVAUInFGPlFQ1RYwYN9H/FpRARzkVoAmwlS3vq6udYu0tZN005pAi/
         OwxD36Ow1hFAgeismRCDV7QYlpkmc/AtiooDflhPKlah3PFpTTcf67+HI/PIMh8YD1db
         v1ok8OK7p3n3ftuWberpVDbg6eP2koYI+WBEf1IOrsiaVjJOgos/WZtnbGoblTttqIM7
         48oNNoO5QMD+xsc6XMz7hg0auZEJY4vSkJg/IhflG1r7Bm/7ITETgb+MEUC7WXxygNJB
         GDjw8gKHSYaGYX5sv2GLUlKRIZSCgARopBiJG+br32xMJTdnWt9ECEeBX0iEeeLEXsd0
         ektA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b8si9519806ple.5.2019.03.12.14.18.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:18:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 47AACE3F;
	Tue, 12 Mar 2019 21:18:55 +0000 (UTC)
Date: Tue, 12 Mar 2019 14:18:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Bartosz Golaszewski <bgolaszewski@baylibre.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Bartosz Golaszewski
 <brgl@bgdev.pl>, Anthony Yznaga <anthony.yznaga@oracle.com>,
 "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, =?UTF-8?B?SsOpcsO0bWU=?=
 Glisse <jglisse@redhat.com>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: remove unused variable
Message-Id: <20190312141854.7a06e640a611344243a25461@linux-foundation.org>
In-Reply-To: <CAMpxmJVeeMRPaXMKp29mE08pKFU4RRMetY=9-pWmazLg3DMLbg@mail.gmail.com>
References: <20190312132852.20115-1-brgl@bgdev.pl>
	<c86234af-a83a-712a-8dc8-0ec2a5dad103@oracle.com>
	<CAMpxmJVeeMRPaXMKp29mE08pKFU4RRMetY=9-pWmazLg3DMLbg@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 15:03:52 +0100 Bartosz Golaszewski <bgolaszewski@baylibre.com> wrote:

> wt., 12 mar 2019 o 14:59 Khalid Aziz <khalid.aziz@oracle.com> napisał(a):
> >
> > On 3/12/19 7:28 AM, Bartosz Golaszewski wrote:
> > > From: Bartosz Golaszewski <bgolaszewski@baylibre.com>
> > >
> > > The mm variable is set but unused. Remove it.
> >
> > It is used. Look further down for calls to set_pte_at().
> >
> > --
> > Khalid
> >
> > >
> > > Signed-off-by: Bartosz Golaszewski <bgolaszewski@baylibre.com>
> > > ---
> > >  mm/mprotect.c | 1 -
> > >  1 file changed, 1 deletion(-)
> > >
> > > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > > index 028c724dcb1a..130dac3ad04f 100644
> > > --- a/mm/mprotect.c
> > > +++ b/mm/mprotect.c
> > > @@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > >               unsigned long addr, unsigned long end, pgprot_t newprot,
> > >               int dirty_accountable, int prot_numa)
> > >  {
> > > -     struct mm_struct *mm = vma->vm_mm;
> > >       pte_t *pte, oldpte;
> > >       spinlock_t *ptl;
> > >       unsigned long pages = 0;
> > >
> >
> >
> 
> Oops, I blindly assumed the compiler is right, sorry for that. GCC
> complains it's unused when building usermode linux. I guess it's a
> matter of how set_pte_at() is defined for ARCH=um. I'll take a second
> look.
> 

The problem is that set_pte_at() is implemented as a macro on some
architectures.

The appropriate fix is to make all architectures use a static inline C
functions in all cases.  That will make the compiler think that the
`mm' arg is used, even if it is not.


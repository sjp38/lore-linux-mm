Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0A31C49ED6
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:20:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8545320872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:20:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="l1enudLK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8545320872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28B086B0003; Tue, 10 Sep 2019 05:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23C776B0007; Tue, 10 Sep 2019 05:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 151BE6B0008; Tue, 10 Sep 2019 05:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0199.hostedemail.com [216.40.44.199])
	by kanga.kvack.org (Postfix) with ESMTP id E68326B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:20:56 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 98B7F68B9
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:20:56 +0000 (UTC)
X-FDA: 75918466512.14.bit45_25491e5445c4e
X-HE-Tag: bit45_25491e5445c4e
X-Filterd-Recvd-Size: 5205
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:20:56 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id t50so16393630edd.2
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:20:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fVGVsESSvCGQOFNvs9wLVPNtEbA+xNhK0Vsp0KuYL0U=;
        b=l1enudLKhX+NelYlOqQKvgNY5xLG29otQPhknZNcMkv0NM6LGktXu52o7Rq9oXni7U
         rT6qa9jJFvVV7DGrQcvT7TkQVr7YPjzLLN2yyQhzqc/3CKUefFYh0Wj1fNGmGs1LrBaU
         +Rt/P8fFgugTd0kFHr2Ss0tY7TIbjyM5B9kitn9D5U0zYDDTKHkZiimf0vIykHPbq2fZ
         mZWj8mIoPkIvn0hdw5gdaffVtvbc7DNotaOw6ScSEUxSsXK+bbSJXldYd/iSPSahFARY
         wygqctO/41VVuzlrbXrPVfgvn1BZBO8SRggWpYtz77R2bRkNGZ3TfXnz9srnNazLkorr
         QBDw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=fVGVsESSvCGQOFNvs9wLVPNtEbA+xNhK0Vsp0KuYL0U=;
        b=gipJGcrlZr5mtbjQD2MbRLL45qWLvlcEgs/PrHchXz97Pm7V850bLZsc5WsejOU5MW
         O2POJWSP+N7mCSIBdrzxUX7wAlC4ivcIeqhu4E3HQO79SxKeczPN0rDEXAMgaLIPx7/p
         /oEdMXkNmUGfencmdj3m0inJgYR6btcp+P2ezlwgDt6O7sfLg5t8PNnsvcpj4hAG/xbL
         RhBVgdrpmjUcdAgKg2hp8pvr42Zz9dRRE0Fh2bkHQ1fCmi7EhDhz+59AUw5txtbwT1Zm
         YwmPGU1NVRzyqZOBwZwroVpn1puOBpvGBEicEgTCrcChnAuuTd62Eh43KjgAeAOhLm/x
         OABw==
X-Gm-Message-State: APjAAAVpULSMwFZ6RFIo4ml6UWjtqJLUOvV7Holq2Af5vQu62OsGoh3X
	dYPgDlCwNF2KGUFL9Hk/HhR3joCb0d6IR+jVy+UNoQ==
X-Google-Smtp-Source: APXvYqxafwr9K7U55nRLBrBFKjJwhzRPMsyqMlNm7SM6xGY0Iw+4afMLkFcRjz7kyMGTKRb774E7d1RrUT7vfuc/ufA=
X-Received: by 2002:aa7:dd17:: with SMTP id i23mr28832869edv.124.1568107254841;
 Tue, 10 Sep 2019 02:20:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
 <20190909181221.309510-11-pasha.tatashin@soleen.com> <60975350-87f8-56b3-437d-d9ee26ac3bd3@suse.com>
In-Reply-To: <60975350-87f8-56b3-437d-d9ee26ac3bd3@suse.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 10 Sep 2019 10:20:43 +0100
Message-ID: <CA+CK2bBK40T_DEhNvz8nQaKSsanxXpGYhBm05N_NmZtq+JDVTg@mail.gmail.com>
Subject: Re: [PATCH v4 10/17] arm64: trans_pgd: make trans_pgd_map_page generic
To: Matthias Brugger <mbrugger@suse.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, kexec mailing list <kexec@lists.infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	James Morse <james.morse@arm.com>, Vladimir Murzin <vladimir.murzin@arm.com>, 
	Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > +/*
> > + * Add map entry to trans_pgd for a base-size page at PTE level.
> > + * page:     page to be mapped.
> > + * dst_addr: new VA address for the pages
> > + * pgprot:   protection for the page.
>
> For consistency please describe all function parameters. From my experience
> function parameter description is normally done in the C-file that implements
> the logic. Don't ask me why.

Ok, I move the comment, and will describe every parameter. Thank you.

>
> > + */
> > +int trans_pgd_map_page(struct trans_pgd_info *info, pgd_t *trans_pgd,
> > +                    void *page, unsigned long dst_addr, pgprot_t pgprot);
> >
> >  #endif /* _ASM_TRANS_TABLE_H */
> > diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
> > index 94ede33bd777..9b75b680ab70 100644
> > --- a/arch/arm64/kernel/hibernate.c
> > +++ b/arch/arm64/kernel/hibernate.c
> > @@ -179,6 +179,12 @@ int arch_hibernation_header_restore(void *addr)
> >  }
> >  EXPORT_SYMBOL(arch_hibernation_header_restore);
> >
> > +static void *
> > +hibernate_page_alloc(void *arg)
>
> AFAICS no new line needed here.

Right, will fix it.

>
> > +{
> > +     return (void *)get_safe_page((gfp_t)(unsigned long)arg);
> > +}
> > +
> >  /*
> >   * Copies length bytes, starting at src_start into an new page,
> >   * perform cache maintenance, then maps it at the specified address low
> > @@ -195,6 +201,10 @@ static int create_safe_exec_page(void *src_start, size_t length,
> >                                unsigned long dst_addr,
> >                                phys_addr_t *phys_dst_addr)
> >  {
> > +     struct trans_pgd_info trans_info = {
> > +             .trans_alloc_page       = hibernate_page_alloc,
> > +             .trans_alloc_arg        = (void *)GFP_ATOMIC,
> > +     };
>
> New line between end of struct and other variables.

Sure.

>
> With these changes:
> Reviewed-by: Matthias Brugger <mbrugger@suse.com>

Thank you,
Pasha


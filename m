Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2842EC28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 07:20:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B61B621473
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 07:20:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="NDyg19KR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B61B621473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D22F6B026F; Sat,  8 Jun 2019 03:20:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 182DD6B0271; Sat,  8 Jun 2019 03:20:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070F16B0273; Sat,  8 Jun 2019 03:20:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB1626B026F
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 03:20:27 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id a62so3783930itd.4
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 00:20:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NRFU6E8aoY/NG8zu/5ScI8y9YPKuPdWK6EZGoPFt9Ck=;
        b=rYj10t/eIHuZXO0cT4VG3blubblnICHx81e8UqTgiQAswWfQRB57i6EUFYaYF6wpUO
         WPkY7/93vqncPcPE+twHeCpfdy8n4o5O6MbTmu7TO20lCbSq2okX7sTKUY0THCnwkHMi
         8VImMgKl/uoC1BI1P9ZI/ChdGP0Y82ByqYMEw2B9CUhjBajKAk5To1jF1UZewjvyl4FW
         MJNbEx/KbBL4TK9SC7iaH13OyBtnj3CFQyfR2YUXHfJRL3R08mYEgJQxddsmRwG0aQvC
         cCipyhNRUBAF360V3AS4v8kzz6KkJfHDZcTUYlVqfv7OpQb2XD2Ath5ENUUgqUTLkLte
         BKhw==
X-Gm-Message-State: APjAAAUXmqeq6yiMLqeDK//7K3crX2Syi9zBi8IxWge6McLAy28/VBCQ
	XCE10gEaLTu8WMqEAjWS4/qTYJvUEWFbwrYfGRCaoNz3Ei5VYsN4FmZhQEU+HGGjvv2x5AJTG8H
	RdcSQ3awRqNDFrhos1CnLD2lzrHU5Ti/IhjIjyG9OVFiMGBJTRpbO9n917k840Z/kQQ==
X-Received: by 2002:a05:660c:1cf:: with SMTP id s15mr6741695itk.78.1559978427542;
        Sat, 08 Jun 2019 00:20:27 -0700 (PDT)
X-Received: by 2002:a05:660c:1cf:: with SMTP id s15mr6741666itk.78.1559978426535;
        Sat, 08 Jun 2019 00:20:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559978426; cv=none;
        d=google.com; s=arc-20160816;
        b=h6khX+D7jvk3jgDb1Iy0QWfw+0pTiAobq8z9IqNDZqjVG7j4jjCOLTRD+NVugRZZds
         Sulr/F6jmTAQ4pPbMq9VjRw8ypmfO3icfUdrVBVTG+X30yB7GUHe1qxiW73QDjAVrP0Y
         mxixmxcAPDmDxurLs4rz5qkfRx4W9N0/2yQLX4hOsBNL7nrcPxViSwqDWqtKXm4w/t83
         R6HBIlG9PdhEEhfhH+ydJDU0nhSXJJr0we7Vbrvb+pKKSwZYKyYA6v6VqPVWJqEfkMnf
         Xjd2RHkcHl24OOhwyTRoa2xoT0bpnQ+ovaBVOQ6sGFIZgsmAC9dpe3LzxrpPUoCzMDOR
         +BzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NRFU6E8aoY/NG8zu/5ScI8y9YPKuPdWK6EZGoPFt9Ck=;
        b=lPlKKzMxMel8bxy7V1Z2fMBPDPtdErAWcapPpIJm66vLrw0lTbT1ArYnjqNQB+KDES
         lDvOprceT2AEb2qStEYNFnyC8A4QyVEHzHpYnI7SFEq7ClChu8VxQptlvFCunkVCSZqj
         EgmXA8y2pmW1qTg8DaM+ZEwSGf7gj68O43P2bhS8dikQPhlwkoEmfscyzADf/Yih2pSH
         55gt4XahVM/hVT/qExM8Qzkl/a1qy7aas6po2XGM0B/ExINrC52ZvSC09H+3qctJcmy7
         ogpkn5mXLKmDBhbmem4MY5rqmiCT1mbMm/HQDraNLqXL5Tvun+O4dIzu5l4iaUrmil8w
         yvxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=NDyg19KR;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p17sor5395235itp.5.2019.06.08.00.20.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Jun 2019 00:20:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=NDyg19KR;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NRFU6E8aoY/NG8zu/5ScI8y9YPKuPdWK6EZGoPFt9Ck=;
        b=NDyg19KRBwWKCsuIiFvg9iRfAOK0BFmH02/xvBLHZXW8TjkcbUXa07UNeCGFNRcVSQ
         8RbFmVpFH1UV2N+/j05HX8NIJQJMtjsgEKFE86KKcUhlfShKCx8Iz8dbQ9Vsx6tckJ5T
         rS+m/g1NYezNDmc1RO4A3Sgo+UodJa8hGFvDUEImNfqv0n+QszCBKoGTKvUhISzRtwkA
         Xb1wAh6WTP39KnlTRX4OirLbaYKQbvdRLkSl+jZyYeOtzDdqjdwK37E0w6E6cb4CmU/O
         DCw//CheJdpE6T4DkIGFn5i6qQUWUaZYBqkDJxVbCvsO0AZmxviK0yDSf2JLaX3ABS1p
         82Rw==
X-Google-Smtp-Source: APXvYqwnMZ8z1ON6onK6aLjM8baTZPCff6UnkQu1+3vja3H65nm9+6f6XC126h9UoGCw6NSPIu5HIfQvokO9SnkaUhk=
X-Received: by 2002:a24:4f88:: with SMTP id c130mr6512194itb.104.1559978425951;
 Sat, 08 Jun 2019 00:20:25 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
 <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
 <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
 <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com>
 <CAPcyv4jO5WhRJ-=Nz70Jc0mCHYBJ6NsHjJNk6AerwQXH43oemw@mail.gmail.com> <CAPcyv4gzhr57xa2MbR1Jk8EDFw-WLdcw3mJnEX9PeAFwVEZbDA@mail.gmail.com>
In-Reply-To: <CAPcyv4gzhr57xa2MbR1Jk8EDFw-WLdcw3mJnEX9PeAFwVEZbDA@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 8 Jun 2019 09:20:13 +0200
Message-ID: <CAKv+Gu_OcsWi5DqxOk-j6ovc0CMAZV37Od7zA5Bs4Ng5ATQxAA@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] x86, efi: Reserve UEFI 2.8 Specific Purpose Memory
 for dax
To: Dan Williams <dan.j.williams@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-efi <linux-efi@vger.kernel.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@redhat.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Darren Hart <dvhart@infradead.org>, 
	Andy Shevchenko <andy@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
	kbuild test robot <lkp@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 7 Jun 2019 at 19:34, Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Fri, Jun 7, 2019 at 8:23 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, Jun 7, 2019 at 5:29 AM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> [..]
> > > > #ifdef CONFIG_EFI_APPLICATION_RESERVED
> > > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > > {
> > > >         return md->type == EFI_CONVENTIONAL_MEMORY
> > > >                 && (md->attribute & EFI_MEMORY_SP);
> > > > }
> > > > #else
> > > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > > {
> > > >         return false;
> > > > }
> > > > #endif
> > >
> > > I think this policy decision should not live inside the EFI subsystem.
> > > EFI just gives you the memory map, and mangling that information
> > > depending on whether you think a certain memory attribute should be
> > > ignored is the job of the MM subsystem.
> >
> > The problem is that we don't have an mm subsystem at the time a
> > decision needs to be made. The reservation policy needs to be deployed
> > before even memblock has been initialized in order to keep kernel
> > allocations out of the reservation. I agree with the sentiment I just
> > don't see how to practically achieve an optional "System RAM" vs
> > "Application Reserved" routing decision without an early (before
> > e820__memblock_setup()) conditional branch.
>
> I can at least move it out of include/linux/efi.h and move it to
> arch/x86/include/asm/efi.h since it is an x86 specific policy decision
> / implementation for now.

No, that doesn't make sense to me. If it must live in the EFI
subsystem, I'd prefer it to be in the core code, not in x86 specific
code, since there is nothing x86 specific about it.

Perhaps a efi=xxx command line option would be in order to influence
the builtin default, but it can be a followup patch independent of
this series.


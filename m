Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0000C48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 20:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B94E20673
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 20:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="yfbm0c70"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B94E20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8B6A6B0003; Fri, 21 Jun 2019 16:06:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3D408E0002; Fri, 21 Jun 2019 16:06:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C52708E0001; Fri, 21 Jun 2019 16:06:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDB06B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:06:51 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a8so3352359otf.23
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 13:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wuEmwyEDkLTTGNEaPaNn66uye06m7pMKJtU3WQzLuW4=;
        b=oO1zBrP0LCxP9jYmbwiHBzQxqDbKr0NrskBbMPTTaz35r59U7OGfWwUgLidHgmtLH7
         N207o3Zl+X+QWAp3Pixu51w6onFCussHkCi4nxDLpQfYd0bAYoXlKt5uwJkLgNUM44CR
         0kuQxBiIm+14uPjFOz6pkU9HUVm5QiNryIjyfFGA9YKV3AcovUR+sxa7Dxb1k4n+1TkA
         OBXShfp6+JbR8EKioOsGQud3S3vU31iu/Hy5MvkA3jVzDCqp7hvRfd+7F0YmeVVf6JD9
         NkXS2qOKDDJi6Bkg2QvTyymEtfw5k2qeGGl8v2h+Upv5lOfez03Kbn8WcJvt3oMTF/HD
         9Q5g==
X-Gm-Message-State: APjAAAXJRpBeBHSpDDz5DA6vjvq30MtG7uPIhMgw4HD3hu8o8j4gzwvx
	uoMuTbKGsEUPSLjcP0u/DKYHCSOFjc9HqXLm5x51TMhWTHQAjRODLKymzd12rL4LUv0SQ6/YwB/
	0JYy0ycj/H+t5BqXmsuQb2DctKuzO4zDkfUlQK/kc/+fZGW/mae77SCMEL8vQp82TMg==
X-Received: by 2002:a05:6830:1249:: with SMTP id s9mr30302830otp.33.1561147611240;
        Fri, 21 Jun 2019 13:06:51 -0700 (PDT)
X-Received: by 2002:a05:6830:1249:: with SMTP id s9mr30302769otp.33.1561147610398;
        Fri, 21 Jun 2019 13:06:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561147610; cv=none;
        d=google.com; s=arc-20160816;
        b=LsjxJ/rJ9GFKntg1Whzq5drVJpeCXA9S5Vqan5D8rEAeAry9V6Gpg36hB7lAxsPeJY
         4M372u8tnDH7SRlvEaMKZSdDaC5aK2RSN1ecwHCTO2187Zef3pluCoa3LeKvpvI4Fwlk
         tlcGUrrTb+C1L6F9UEt61X3OfvvPHqlMAxiQf/4UO916Q/bPcusuUG7bTgy62ZNqAMPr
         Q9IWud29W/7WAdYm79mIxuR974OrWYKBtsCyzMd/0JXCJfO84cTXqQZ4cb/rAuD7eBMv
         sKC6mpwIi/YZ+Q4+Ts2olvwPGPlRrZLmHFLkhM45oiitrFVb2h/nIlC8a4sGvsV7AR86
         +mAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wuEmwyEDkLTTGNEaPaNn66uye06m7pMKJtU3WQzLuW4=;
        b=szRSeLCAq5ez/1p/eL3os6N45FXdJ21vLGFNy9/VaBEDKaTXnRDgbDVZBTd2nsFo1n
         Vd8d443zjwwKyPICk+bpSQKwYrnez0aajm2XUf+vxzP/HAKzq01bt0MSVQSM/JN78XTZ
         McDvsfJElulF1CPJ77zCrU+Xo+xB6B+40hckYwj8/aHtrDzzpHlL/NH+/Pww4HGc1rOR
         +9G9dleeRDxPpdAHYRiYr3cg5EJfXYxv+uoTyyTB7WZotMsapqDwz+GwVHIXKUIVMc7O
         UENf2EIRoI9Ow0t1PWgtMRQ3lQBW0tqK+7r8gC4CMr3ZEgD/HW4qhUp1dygeUJfEE5eo
         c++Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yfbm0c70;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor2311222otd.150.2019.06.21.13.06.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 13:06:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yfbm0c70;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wuEmwyEDkLTTGNEaPaNn66uye06m7pMKJtU3WQzLuW4=;
        b=yfbm0c70FRxPQvT9ttNxjjuYHrLEhwZtbnY9goMK/0Gx78N5J7QrZtLuREOupTptR5
         Q6lMBj1OahoCaUeB5vb1WpR4k3yMCiTX9SiElfshDMd+oBYiR1iPaQpsP3rMRLV+fSfm
         oj5j9y4v4Mg8Pe4WYVpkvn6QZ9nFF4tNNmw85cboZbNy52Hu9yzqSZDa8Jvf30gP6dUz
         JQ0KfefwxJcxn6gxZ7nWCvnoUnPVLI04pktSbH5XZ1iNtk6tTUJzw9EBK2RHX7rELfXD
         jI5SVdxRvya4HhOWrk1C1ZpVxSQVBFjWZ3gh2npuCk2Bn4G3E8FRKUDJN6SxlHpBOMm6
         FRoA==
X-Google-Smtp-Source: APXvYqyQOOqbJLjW2BcOmlG77qXX9/WsYin5lYao1Mf2DKSbEZ6q1C3Ab3BvZSOCGLndw9OyPK8hja1kJE7joCwf+Qo=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr1671387otk.363.1561147610028;
 Fri, 21 Jun 2019 13:06:50 -0700 (PDT)
MIME-Version: 1.0
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155925718351.3775979.13546720620952434175.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAKv+Gu-J3-66V7UhH3=AjN4sX7iydHNF7Fd+SMbezaVNrZQmGQ@mail.gmail.com>
 <CAPcyv4g-GNe2vSYTn0a6ivQYxJdS5khE4AJbcxysoGPsTZwswg@mail.gmail.com>
 <CAKv+Gu83QB6x8=LCaAcR0S65WELC-Y+Voxw6LzaVh4FSV3bxYA@mail.gmail.com>
 <CAPcyv4hXBJBMrqoUr4qG5A3CUVgWzWK6bfBX29JnLCKDC7CiGA@mail.gmail.com>
 <CAKv+Gu_ZYpey0dWYebFgCaziyJ-_x+KbCmOegWqFjwC0U-5QaA@mail.gmail.com>
 <CAPcyv4jO5WhRJ-=Nz70Jc0mCHYBJ6NsHjJNk6AerwQXH43oemw@mail.gmail.com>
 <CAPcyv4gzhr57xa2MbR1Jk8EDFw-WLdcw3mJnEX9PeAFwVEZbDA@mail.gmail.com> <CAKv+Gu_OcsWi5DqxOk-j6ovc0CMAZV37Od7zA5Bs4Ng5ATQxAA@mail.gmail.com>
In-Reply-To: <CAKv+Gu_OcsWi5DqxOk-j6ovc0CMAZV37Od7zA5Bs4Ng5ATQxAA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 21 Jun 2019 13:06:38 -0700
Message-ID: <CAPcyv4hB7EbxkcDGc1j2vXwFcX5rHOYtRZcRa7Q36CVrAk1w+g@mail.gmail.com>
Subject: Re: [PATCH v2 4/8] x86, efi: Reserve UEFI 2.8 Specific Purpose Memory
 for dax
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
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

On Sat, Jun 8, 2019 at 12:20 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> On Fri, 7 Jun 2019 at 19:34, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, Jun 7, 2019 at 8:23 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Fri, Jun 7, 2019 at 5:29 AM Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> > [..]
> > > > > #ifdef CONFIG_EFI_APPLICATION_RESERVED
> > > > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > > > {
> > > > >         return md->type == EFI_CONVENTIONAL_MEMORY
> > > > >                 && (md->attribute & EFI_MEMORY_SP);
> > > > > }
> > > > > #else
> > > > > static inline bool is_efi_application_reserved(efi_memory_desc_t *md)
> > > > > {
> > > > >         return false;
> > > > > }
> > > > > #endif
> > > >
> > > > I think this policy decision should not live inside the EFI subsystem.
> > > > EFI just gives you the memory map, and mangling that information
> > > > depending on whether you think a certain memory attribute should be
> > > > ignored is the job of the MM subsystem.
> > >
> > > The problem is that we don't have an mm subsystem at the time a
> > > decision needs to be made. The reservation policy needs to be deployed
> > > before even memblock has been initialized in order to keep kernel
> > > allocations out of the reservation. I agree with the sentiment I just
> > > don't see how to practically achieve an optional "System RAM" vs
> > > "Application Reserved" routing decision without an early (before
> > > e820__memblock_setup()) conditional branch.
> >
> > I can at least move it out of include/linux/efi.h and move it to
> > arch/x86/include/asm/efi.h since it is an x86 specific policy decision
> > / implementation for now.
>
> No, that doesn't make sense to me. If it must live in the EFI
> subsystem, I'd prefer it to be in the core code, not in x86 specific
> code, since there is nothing x86 specific about it.

The decision on whether / if to take any action on this hint is
implementation specific, so I argue it does not belong in the EFI
core. The spec does not mandate any action as it's just a hint.
Instead x86 is making a policy decision in how it translates it to the
x86-specific E820 representation. So, I as I go to release v3 of this
patch set I do not see an argument to move the
is_efi_application_reserved() definition out of
arch/x86/include/asm/efi.h it's 100% tied to the e820 translation.

Now, if some other EFI supporting architecture wanted to follow the
x86 policy we could move it it to a shared location, but that's
something for a follow-on patch set.


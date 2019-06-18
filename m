Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B89BC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:30:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 317632080A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:30:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ub6bbFJz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 317632080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC00B6B0003; Tue, 18 Jun 2019 14:30:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71F98E0002; Tue, 18 Jun 2019 14:30:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5EC68E0001; Tue, 18 Jun 2019 14:30:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0236B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:30:36 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b4so6706068otf.15
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:30:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=QURH9BlGMn5ivsBiRhffgAaGzwMxDE7JjHw07LOOJ3U=;
        b=uWGS9ORaLTL1PNgz3i0iX5AkNeo1waGoptXU9rmGA5G/XZ1lcNMgLUi1T5u+mkkrpK
         clg7qryWK5rcn9NoxqVEPOhj49iqaBTP99Ty33lsnX1XvYrWeR9UgCwRoTIUq+H0ByBT
         8F8g7KR/hRtxnkt2zTnZAW7zXATkRB9ZSBa/5HuptqDEBAv7y3Nx0s46w96+N2LbmFaf
         ocOl2tiDK9oNvAjGv9cmkq5neQwSMOmeEn1dPYAIJa9QJdYpYcAXNA3qYH+nUZawqo5X
         bpPqTGOWJF7/ooUhIhBbCJ9lMizeMaGoG/JLTc4/XjYRneuxDCL94//vYejul3C/Zy2y
         S09g==
X-Gm-Message-State: APjAAAVCwP+WxmKvVrks850DeZjBa+yTW6mYAYfI8ZR1DTbhhK362bk1
	oRBRk0fXSByzqyoUAJKGjHMPjfQ6kWco3Ay4xJMZYRsOJYM5TlcKbXeNQSl/kcsyd0bFSKfaOdf
	7iH2FdVPGAWSEFt5KSN4+JTUnBM4G25PqhAzY1okflw7/FtteuimcTXtrPi2yqijdoA==
X-Received: by 2002:a9d:1426:: with SMTP id h35mr60599934oth.55.1560882636105;
        Tue, 18 Jun 2019 11:30:36 -0700 (PDT)
X-Received: by 2002:a9d:1426:: with SMTP id h35mr60599867oth.55.1560882635385;
        Tue, 18 Jun 2019 11:30:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560882635; cv=none;
        d=google.com; s=arc-20160816;
        b=cX30ZHBYpRAYXT6AKo9brLMhnChlHs5QYvxqta+G5rcJv7ued1IFBanvKFBWU1YsBA
         uIHkLqQcmVzxLSdsiGzMtmLBmE+ikHK1XqXjzgvQf7Q08Toxkt9KHm1V/3t9Ych6b39S
         HPJvMFj4tLd37iaasXkkrTLbCpgvv4piZiA7/ajNnTzLt0rcpVMDShUU945bXo8lfxxS
         bmJtdBjGnubnUZbNYoLwop+fcF3dw/0EFG6R1btW26enWlGhyb7RcKEGLt57i+R11Ieu
         /KYR4nxkBk6aejJKYrZLO4jvH9Igt9QM5U+BSOZX+Uc6jom3cY+latcUlu86qKHCTVz2
         x66w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=QURH9BlGMn5ivsBiRhffgAaGzwMxDE7JjHw07LOOJ3U=;
        b=mEMNwvs5zqWzh0B6xC5MouxaI7lvRLxkHW59hFUdqun/GynKItvQAQAWR6mJq/NPTd
         M61/HrOvaTz+7QepeMMhBAXX2R7gOkXGzNfhSAMB6iCM6v1JK6OHJlQQgfhSIzrKlesG
         XAUDbqmsygBD7+XiGL5kgAM+fFqGWEjIaus6kMAVVIY/pyiyiHdN6BzXzC6vjBBOuGTd
         cKhOC+a0MMxw45REpOWPM5hobuVA/xnOPcQ8OKFuT65UUIRAPv7FhqGpd1WY9/e3Lo2t
         z7fCxV50RJ/UsQMTC2VTvmuN38/yJQBb6CVWRRTMgj2cKQO7RHfGJsvRCpqd5fsBOr5Y
         aKbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ub6bbFJz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k6sor7554152otj.42.2019.06.18.11.30.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 11:30:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ub6bbFJz;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=QURH9BlGMn5ivsBiRhffgAaGzwMxDE7JjHw07LOOJ3U=;
        b=ub6bbFJz3cGKP4DJvWt4cUVqnMPw0tYXYidWbWXz5IxojFBYfjQ8+NZNM0A1parMjg
         XuFtTjWosbXHYsKY5pvZ5h+rYeB1mauKvpUBx4cgQrogpBjgrJMwYDtS3nIClop4mXlI
         K1OFS3VCjjxATk1/fHRb3qM66QJ7N04Z7iRdxfnsHDIM6jfupT4uo0uS34WafuE5lwzp
         FurJGKVyNOq9jawJJg3WekhcWtRoOty1/Qq2q6C4tCl2eJFzHji0sZCBR/nizOARyhOi
         iudVj04uNutBsNfwMWZMlqzV1RPKKk1YzjBxEEfA/qewB6FXwktk1tkFRmWhTOP2u+7Q
         /VDg==
X-Google-Smtp-Source: APXvYqzgZ0IGDjeEZoDLAA85SSKphkLslMWxC7Pq+36Ps83jAVNEXt1pNtzBuZDXh16tYO6i1b9YAg3RzegDs+Djppw=
X-Received: by 2002:a9d:7a46:: with SMTP id z6mr281269otm.2.1560882635053;
 Tue, 18 Jun 2019 11:30:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
 <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com>
In-Reply-To: <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 18 Jun 2019 11:30:23 -0700
Message-ID: <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
To: Nadav Amit <namit@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra <peterz@infradead.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Ingo Molnar <mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 10:42 AM Nadav Amit <namit@vmware.com> wrote:
>
> > On Jun 17, 2019, at 11:44 PM, Dan Williams <dan.j.williams@intel.com> w=
rote:
> >
> > On Wed, Jun 12, 2019 at 9:59 PM Nadav Amit <namit@vmware.com> wrote:
> >> Running some microbenchmarks on dax keeps showing find_next_iomem_res(=
)
> >> as a place in which significant amount of time is spent. It appears th=
at
> >> in order to determine the cacheability that is required for the PTE,
> >> lookup_memtype() is called, and this one traverses the resources list =
in
> >> an inefficient manner. This patch-set tries to improve this situation.
> >
> > Let's just do this lookup once per device, cache that, and replay it
> > to modified vmf_insert_* routines that trust the caller to already
> > know the pgprot_values.
>
> IIUC, one device can have multiple regions with different characteristics=
,
> which require difference cachability.

Not for pmem. It will always be one common cacheability setting for
the entirety of persistent memory.

> Apparently, that is the reason there
> is a tree of resources. Please be more specific about where you want to
> cache it, please.

The reason for lookup_memtype() was to try to prevent mixed
cacheability settings of pages across different processes . The
mapping type for pmem/dax is established by one of:

drivers/nvdimm/pmem.c:413:              addr =3D
devm_memremap_pages(dev, &pmem->pgmap);
drivers/nvdimm/pmem.c:425:              addr =3D
devm_memremap_pages(dev, &pmem->pgmap);
drivers/nvdimm/pmem.c:432:              addr =3D devm_memremap(dev,
pmem->phys_addr,
drivers/nvdimm/pmem.c-433-                              pmem->size,
ARCH_MEMREMAP_PMEM);

...and is constant for the life of the device and all subsequent mappings.

> Perhaps you want to cache the cachability-mode in vma->vm_page_prot (whic=
h I
> see being done in quite a few cases), but I don=E2=80=99t know the code w=
ell enough
> to be certain that every vma should have a single protection and that it
> should not change afterwards.

No, I'm thinking this would naturally fit as a property hanging off a
'struct dax_device', and then create a version of vmf_insert_mixed()
and vmf_insert_pfn_pmd() that bypass track_pfn_insert() to insert that
saved value.


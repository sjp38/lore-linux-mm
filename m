Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 110EEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 04:02:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9060D20854
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 04:02:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="eU7vf8X9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9060D20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E61968E0003; Thu, 14 Mar 2019 00:02:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10238E0001; Thu, 14 Mar 2019 00:02:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFF868E0003; Thu, 14 Mar 2019 00:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD0C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 00:02:25 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id n205so1808195oif.18
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 21:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qs7tp1/zBqGtB73b9T3ZkeYLG/1DJ1WgPchIkfxvgMI=;
        b=dIo2OmfCevSGpmAkJzW5ISygFE4U2hX3IhQCR/Tw9rYp4rymYrBrE7u9FJCRlSTx0N
         JcXXB7qI+AR6ozj0MagxYCOzsvUPWyheAYyDBCsagvduHtDfzTgjYpkrsQ77KeenE8k4
         iIkSHAm9OzTqSQj9VlZ5ebitlLQo9iFBGYQZSoh6twrCcTJk10V8hLeIrpoYL4tMz5ly
         J77+1U/xCMUEE4nVbXQLTeUCKkMt6oaGNtR6nx/vHBfaTM/uiv3kjQ0zEH7CIPlfibSk
         +tmeLaRSrKcod/KuZOOhwfBqGT0LKOMqGhgEL7YtBnbsPk/u0l5RquOy+u3j0l2CXhia
         m+dw==
X-Gm-Message-State: APjAAAUEzC7hDzJmDO8yf16VgphxEqbWN2f1vsq3hkbXugvuwYnyQ2j1
	WY/uqiHwiYEABIGvqTMB7XVvfnb0/IcZDQ3l48yKdILDDzzwgE5g7YnfwW4jjvQ3K7USHZl8B2h
	XiZFM7K4k5NK02gZLlkiTfV79nOK5hhr4am+LDeIY9D22bgeXRBTBbVAGt0vfKhkdYvfTua5ATN
	Gb8VduJcf1ZATIepZSFPKBrZiPhIPtrftccqsFE/rFQDfldlTrjKUaeiT2c65WeGA+Bf4b9cKrw
	8XzOZz6UAQ/mcxDSZc8lwct+OjbhOUUAIFTuvGeIGcsOYzT04d7fRHWjJqQTx5O1Tof+TBLnfsR
	URNLd/ovjdU1c1tWIXGEAp3KjjqIYD3bFT8Zft2vvoX518c7NnHuyNRI/+G5qB9pKxM6sUUhkCb
	L
X-Received: by 2002:a9d:480c:: with SMTP id c12mr13464068otf.290.1552536145195;
        Wed, 13 Mar 2019 21:02:25 -0700 (PDT)
X-Received: by 2002:a9d:480c:: with SMTP id c12mr13464041otf.290.1552536144371;
        Wed, 13 Mar 2019 21:02:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552536144; cv=none;
        d=google.com; s=arc-20160816;
        b=iWReRFfpngJPfEoReqk9cf1VBawScZlETv1OY+t3WT2PGCBfTBQyMIW6jJzjjEOayl
         u/kIRfqDmJK+GlKlrLjy1IhfO4GtVvH4VQx4zygwamA45Tvm2/j24yh9QlIO8txJP6zs
         lL6Kw/04nkCqfJ7Rgwjeleif3g3E5AlxCNaXZaD+5oC+vzWMy13RstMzx6mwFmThybDy
         cJBcsKhVyShCjf83UWvfSv1tPbeeJ5TnZz1B/f5OHmX5YTlWPskI8RSsZ5RuKiQRFrzQ
         lDr4L6Vb63yG5CB+UenMsrdLrKVC/dbEgiR6sv87vX3OOfUq/o2LpPCYSoM7qc49HRwK
         Mhcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qs7tp1/zBqGtB73b9T3ZkeYLG/1DJ1WgPchIkfxvgMI=;
        b=zxMWdIrzOqbceAK1S7VaIfay9V0I8FUeJZcPsjU6pH43vUxv0S9WU7pSvEzVeP7j8b
         VQM5qkWHpEN4jGtBI3M+lTN1OUjnGqMp9SLrDc0Ej5m+J/jY9CpBL/h3OQwmTUmCe8L/
         fE15hMkgBkd8GQlQJVnIa3N2ERxOaaPDiwcpEbFq7+fG5om8g9Xw2ekuLojyNRQULsl9
         kATXK2+WlX/kfjBXUbtH/8yc/IEHCHDJ4kCgXG2mAbuMpmjuOomYBjRdss0CqRUen+rP
         7KiPj0REwh+u4Px7KHhzWoJpT3QTlV/7NiGb7mP6n+N5DSSfqT8aTHsqE0IUVzBgcrQb
         AgKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=eU7vf8X9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m25sor1821478otl.59.2019.03.13.21.02.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 21:02:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=eU7vf8X9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qs7tp1/zBqGtB73b9T3ZkeYLG/1DJ1WgPchIkfxvgMI=;
        b=eU7vf8X9XCVloH4yFRSwPMJOtpSR/fMmFkniq4uHcPXAlIReWXJh0Z+q64meRuGP3M
         skI5X4A5JF/zw1rhA6o7JcFS6QQUIjOyw87HiIPJuTeV3ZFCWkuVzjiunjbGmnKIH8PP
         d0GUJS45X4BfE3LGcOkOgmFPbVoD1RlmOP/s4Iba+KMHCV7RQOG8tt5WRNcYCxFV8yGB
         uQgbxTR+iAgUImDt6CTAyz2+XDvw6vYu7YGLKi1XurFi/KZX9rHUjIia18cI51xDn6FC
         vI2KT31oSMg20EO444p+DGxfHVR1APWOjIF4q0elCkXZ/5bHEVX7dTtHnmLFxCnjmC/E
         9rXA==
X-Google-Smtp-Source: APXvYqzxaRxDED7CM3oENetDG2md4WXlntPbG0NSGcR0/oaZGUe6x6pBOyPAF61pD1lSSIn/hEMAOHQHBo57G6q1bYU=
X-Received: by 2002:a9d:77d1:: with SMTP id w17mr28800858otl.353.1552536143794;
 Wed, 13 Mar 2019 21:02:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
 <871s3aqfup.fsf@linux.ibm.com>
In-Reply-To: <871s3aqfup.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Mar 2019 21:02:11 -0700
Message-ID: <CAPcyv4i0SahDP=_ZQV3RG_b5pMkjn-9Cjy7OpY2sm1PxLdO8jA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Ross Zwisler <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 8:45 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
[..]
> >> Now w.r.t to failures, can device-dax do an opportunistic huge page
> >> usage?
> >
> > device-dax explicitly disclaims the ability to do opportunistic mappings.
> >
> >> I haven't looked at the device-dax details fully yet. Do we make the
> >> assumption of the mapping page size as a format w.r.t device-dax? Is that
> >> derived from nd_pfn->align value?
> >
> > Correct.
> >
> >>
> >> Here is what I am working on:
> >> 1) If the platform doesn't support huge page and if the device superblock
> >> indicated that it was created with huge page support, we fail the device
> >> init.
> >
> > Ok.
> >
> >> 2) Now if we are creating a new namespace without huge page support in
> >> the platform, then we force the align details to PAGE_SIZE. In such a
> >> configuration when handling dax fault even with THP enabled during
> >> the build, we should not try to use hugepage. This I think we can
> >> achieve by using TRANSPARENT_HUGEPAEG_DAX_FLAG.
> >
> > How is this dynamic property communicated to the guest?
>
> via device tree on powerpc. We have a device tree node indicating
> supported page sizes.

Ah, ok, yeah let's plumb that straight to the device-dax driver and
leave out the interaction / interpretation of the thp-enabled flags.

>
> >
> >>
> >> Also even if the user decided to not use THP, by
> >> echo "never" > transparent_hugepage/enabled , we should continue to map
> >> dax fault using huge page on platforms that can support huge pages.
> >>
> >> This still doesn't cover the details of a device-dax created with
> >> PAGE_SIZE align later booted with a kernel that can do hugepage dax.How
> >> should we handle that? That makes me think, this should be a VMA flag
> >> which got derived from device config? May be use VM_HUGEPAGE to indicate
> >> if device should use a hugepage mapping or not?
> >
> > device-dax configured with PAGE_SIZE always gets PAGE_SIZE mappings.
>
> Now what will be page size used for mapping vmemmap?

That's up to the architecture's vmemmap_populate() implementation.

> Architectures
> possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
> device-dax with struct page in the device will have pfn reserve area aligned
> to PAGE_SIZE with the above example? We can't map that using
> PMD_SIZE page size?

IIUC, that's a different alignment. Currently that's handled by
padding the reservation area up to a section (128MB on x86) boundary,
but I'm working on patches to allow sub-section sized ranges to be
mapped.

Now, that said, I expect there may be bugs lurking in the
implementation if PAGE_SIZE changes from one boot to the next simply
because I've never tested that.

I think this also indicates that the section padding logic can't be
removed until all arch vmemmap_populate() implementations understand
the sub-section case.


Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52373C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:22:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12E8D2339E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:22:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arm-com.20150623.gappssmtp.com header.i=@arm-com.20150623.gappssmtp.com header.b="1snVJDaz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12E8D2339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8814D6B0003; Wed,  4 Sep 2019 10:22:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 833566B0006; Wed,  4 Sep 2019 10:22:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 748BA6B0007; Wed,  4 Sep 2019 10:22:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0074.hostedemail.com [216.40.44.74])
	by kanga.kvack.org (Postfix) with ESMTP id 562246B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:22:17 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E60B92C8A
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:22:16 +0000 (UTC)
X-FDA: 75897453072.03.salt38_88416c5dbcd43
X-HE-Tag: salt38_88416c5dbcd43
X-Filterd-Recvd-Size: 5655
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:22:16 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id d3so9673255plr.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 07:22:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arm-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zLfyPE0SwETDkvtq1bsqjNVDjHFo5NFhYLI0JJDHf+U=;
        b=1snVJDaz07aE2jmpN2RYpCQk1j6M/Srf+5TWc6mM9g3qTtc/LGhpFS8SBr3wKWtEUs
         2vYCnwXgW9GP8u+jBChNFuPMJ8iwZ9V7Xcr5VSkZ9pwacLNBnQbE0mDlDmHrKh6ex7KU
         dEWnsOFqHjya8jp54mNersHodjBUqcvphyH7IfadVYLHKiPHrbJWewxG3TVx7nFeFjiN
         rQk268Xl9j6jNOHV5Tft4pL4TgqePxl2lKQ7MPMfBiNESFOZceoezwFHn8NU4khM2WX0
         p/zEYa4oRctpb7xuorIQkOq1Zv3b4yQo/bzlGSKATz5xFIwT+rPVQBDntFMkz5DnGdMA
         4y8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=zLfyPE0SwETDkvtq1bsqjNVDjHFo5NFhYLI0JJDHf+U=;
        b=jTh5E0njM7v/gONKl7zkjf/U+ouzxfDaqG8eleUi6OWlOT9noVfQelVaJ/a0Yl1KEz
         db1mFMHImZC5T3cNZoWotQW3ICAqHLNkwappW1W/XemTZyVa9TDPDglTZOSQzH2X4pJF
         pBI7nE0xh6ayw3vqk5yF30vbUz4tCAlGMJwT/rtPPKalSgMGg1DlyxkgjpkPml5NwmAx
         PV7ZK8AhntYtrKEKEk7KOrE6bN3rn7rp8ZCY9V1yGU4wzt2u6roR+oOrs+LQVY1WBgcy
         5cC0/L5Oa0vj3rqrFzzGUxmKlkAqALTF6R+a+zSN9MnfHYPkOfC/FZe+4n8dGyBiNp8u
         l/3A==
X-Gm-Message-State: APjAAAUs/QrrCLFkT/fraBGzIzMrm0xS4v03HfNRLgXsMulbUwAifJC9
	fuWa41s8IQBOY50JRjdTfpyOFVOFj752us4yW8mmuER1xf4=
X-Google-Smtp-Source: APXvYqwXlRS/Ftz/KVLDn4/l/NIOLb/ncyHE2q5troSsqlmTwDtLGgmlgtnwK5RjJr9zJVjSABvjyUk7dHWl92vOS74=
X-Received: by 2002:a17:902:8a93:: with SMTP id p19mr41493501plo.106.1567606935073;
 Wed, 04 Sep 2019 07:22:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190904005831.153934-1-justin.he@arm.com> <fd22d787-3240-fe42-3ca3-9e8a98f86fce@arm.com>
In-Reply-To: <fd22d787-3240-fe42-3ca3-9e8a98f86fce@arm.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 4 Sep 2019 15:22:03 +0100
Message-ID: <CAHkRjk6cQTu7N+UanTspWm_LyABRhfPHQn1+PPdaHYrTC3PtfQ@mail.gmail.com>
Subject: Re: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Jia He <justin.he@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Matthew Wilcox <willy@infradead.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Peter Zijlstra <peterz@infradead.org>, Dave Airlie <airlied@redhat.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Thomas Hellstrom <thellstrom@vmware.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2019 at 04:20, Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
> On 09/04/2019 06:28 AM, Jia He wrote:
> > @@ -2152,20 +2153,30 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
> >        */
> >       if (unlikely(!src)) {
> >               void *kaddr = kmap_atomic(dst);
> > -             void __user *uaddr = (void __user *)(va & PAGE_MASK);
> > +             void __user *uaddr = (void __user *)(vmf->address & PAGE_MASK);
> > +             pte_t entry;
> >
> >               /*
> >                * This really shouldn't fail, because the page is there
> >                * in the page tables. But it might just be unreadable,
> >                * in which case we just give up and fill the result with
> > -              * zeroes.
> > +              * zeroes. If PTE_AF is cleared on arm64, it might
> > +              * cause double page fault here. so makes pte young here
> >                */
> > +             if (!pte_young(vmf->orig_pte)) {
> > +                     entry = pte_mkyoung(vmf->orig_pte);
> > +                     if (ptep_set_access_flags(vmf->vma, vmf->address,
> > +                             vmf->pte, entry, vmf->flags & FAULT_FLAG_WRITE))
> > +                             update_mmu_cache(vmf->vma, vmf->address,
> > +                                             vmf->pte);
> > +             }
> > +
> >               if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
>
> Should not page fault be disabled when doing this ?

Page faults are already disabled by the kmap_atomic(). But that only
means that you don't deadlock trying to take the mmap_sem again.

> Ideally it should
> have also called access_ok() on the user address range first.

Not necessary, we've already got a vma and the access to the vma checked.

> The point
> is that the caller of __copy_from_user_inatomic() must make sure that
> there cannot be any page fault while doing the actual copy.

When you copy from a user address, in general that's not guaranteed,
more of a best effort.

> But also it
> should be done in generic way, something like in access_ok(). The current
> proposal here seems very specific to arm64 case.

The commit log didn't explain the problem properly. On arm64 without
hardware Access Flag, copying from user will fail because the pte is
old and cannot be marked young. So we always end up with zeroed page
after fork() + CoW for pfn mappings.

-- 
Catalin


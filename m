Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AB55C3A5A9
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:49:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4BCA23401
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 13:49:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arm-com.20150623.gappssmtp.com header.i=@arm-com.20150623.gappssmtp.com header.b="Nf7bZgM8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4BCA23401
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42DCB6B0003; Wed,  4 Sep 2019 09:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DE3C6B0006; Wed,  4 Sep 2019 09:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CD3F6B0007; Wed,  4 Sep 2019 09:49:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0159.hostedemail.com [216.40.44.159])
	by kanga.kvack.org (Postfix) with ESMTP id 0FBC36B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 09:49:30 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 892D3180AD802
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:49:29 +0000 (UTC)
X-FDA: 75897370458.22.party10_8d0732a687431
X-HE-Tag: party10_8d0732a687431
X-Filterd-Recvd-Size: 4569
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 13:49:29 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id w22so4836875pfi.9
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 06:49:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arm-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+p6RR38peQrVv1PKhrGG8NO7Bt9/0+SxJtAUeqEkoto=;
        b=Nf7bZgM8mdEbmKwjRCrour8SaCg74ZrKw+SpmXqlfKcAGQajEWCuuabuloY4nXrZmf
         QCxk0gobu4cCn1YuYRos+Eod7P6TD6+1vj8PFxkLu90DN4/ZFSxNPINOortGSSQ+Ce6H
         mMPI0BoIiFvzOTW2eZk2V8PG3f++AswYk1b6rvTf82GawDUQLmC794fDW7eyIdUPrjG7
         mYOnKMEdeFdkEROHDvOl7vIe9eeb3k2R2O+OSIel668XhegPMcFdRaQvDiyu3Sj1mS0f
         gGvOzjeLwbGylGMBpVAUlFet4b3qCztEKmcFJxcAl+Fb6l5GAV/otZqEd7iCXSRU8kYI
         /22w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+p6RR38peQrVv1PKhrGG8NO7Bt9/0+SxJtAUeqEkoto=;
        b=lPmnF/l5yRqL4qV4izQ4LkYNOU0XTtG6pVWuPUzNuetWwf/B5s+TSicrHxFJDWowXz
         4dxJCUHJyL4UslcZiyVy9HYHfQ3YqjjWDFID+vEvTeXhHvKqAuMuYv9Qx+cmdBJpfW1M
         k3GOX+yeAvHH+wmWQAhOehv2X5F+8IRt5mdmXQDBJVMeGh9degRJ2QG/GzoppngEW3if
         B111dxrdJez2auaTpemnnGxyENc/OLtqbiAudos2617x7fJn8jXf1+sMIjd3+aTc3sG7
         Oh0PMEsXYW2b+NDJjzKNtH7TBdsqRmPAiB1dgWgl+6ptw6AeZkA/2SSef2BnB4icAXNV
         lJoQ==
X-Gm-Message-State: APjAAAW2eB8D1CB9f/BcTBBLKcBDcCSjxVLIhz/yjvEey2QCalhWOI/K
	ydjoWwI1A0cs5KxMcTshiIJ3d7NFgP08HLF0bHs=
X-Google-Smtp-Source: APXvYqyGjj0H1IaJHd1+uKPzC9oFjuz19QOcJsawYhcxEkhQYTyd1ZMRedf9zVScirVCb+IYMMfOgvVOhbznJz1gkBQ=
X-Received: by 2002:a17:90a:7f81:: with SMTP id m1mr5125780pjl.92.1567604967944;
 Wed, 04 Sep 2019 06:49:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190904005831.153934-1-justin.he@arm.com>
In-Reply-To: <20190904005831.153934-1-justin.he@arm.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 4 Sep 2019 14:49:16 +0100
Message-ID: <CAHkRjk7jNeoXz_zg6KmTam-pAzO3ALFARS91w+zZHmZN_9JsTg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix double page fault on arm64 if PTE_AF is cleared
To: Jia He <justin.he@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
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

On Wed, 4 Sep 2019 at 01:59, Jia He <justin.he@arm.com> wrote:
> @@ -2152,20 +2153,30 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>          */
>         if (unlikely(!src)) {
>                 void *kaddr = kmap_atomic(dst);
> -               void __user *uaddr = (void __user *)(va & PAGE_MASK);
> +               void __user *uaddr = (void __user *)(vmf->address & PAGE_MASK);
> +               pte_t entry;
>
>                 /*
>                  * This really shouldn't fail, because the page is there
>                  * in the page tables. But it might just be unreadable,
>                  * in which case we just give up and fill the result with
> -                * zeroes.
> +                * zeroes. If PTE_AF is cleared on arm64, it might
> +                * cause double page fault here. so makes pte young here
>                  */
> +               if (!pte_young(vmf->orig_pte)) {
> +                       entry = pte_mkyoung(vmf->orig_pte);
> +                       if (ptep_set_access_flags(vmf->vma, vmf->address,
> +                               vmf->pte, entry, vmf->flags & FAULT_FLAG_WRITE))

I think you need to pass dirty = 0 to ptep_set_access_flags() rather
than the vmf->flags & FAULT_FLAG_WRITE. This is copying from the user
address into a kernel mapping and the fault you want to prevent is a
read access on uaddr via __copy_from_user_inatomic(). The pte will be
made writable in the wp_page_copy() function.

-- 
Catalin


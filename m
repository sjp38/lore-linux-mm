Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9601AC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DFC32173E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:17:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BozsRedf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DFC32173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7DD16B0003; Wed, 22 May 2019 17:17:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2EFE6B0006; Wed, 22 May 2019 17:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1D2A6B0007; Wed, 22 May 2019 17:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1D56B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:17:11 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id 45so945359ual.21
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4dHniiz5Iec+zX/39XStbUXbmPxCKmuaK7gygHepfyc=;
        b=m437eZG1uGMIoh9Yx79r2Vz9IZ/so8UD6d8829lbI9b/DTHImsD6pR41NHPmfJq7VL
         gi2nhsoptnTgy6NqWybviZRhC2w7qI8MX6Y+rsUdqOM7MoCpeqAZspp0O7wZFjxCBZBM
         +089UfZ6SCq1aDf1ujhu1oVDKUng7CxASH2j1Cp5pThGGWUG3QFjf8PuvYUHw6fVp4Wc
         IDaol1Bw+wju+FoA2FLh19+ZpX2Po+tAS71g/VJ8aZg1TP1onpiryQBq7349iNOSf3qu
         SPVVHhhaiNlK2dwvKZPaaP79Po5cRq3skNoeBivvEcghJi8qGCYh/CtVTCk7YJej15Vu
         4Nvg==
X-Gm-Message-State: APjAAAXYIAJyNKnYUdrw1/tciLTaOUjmfR/LTgt44GOFGJyRqlG8NE34
	lguRn6rxq2AdpvcV99IiQQDMxxRbECfSdj+6pt9ItccA6BB2d6rClo3eHCSzGersq3xghqqqLTJ
	cnuew96Z/AyrZoSYBY9cKem1avTXo/L5wk5ILB5IPoIomMujECRULxateMEC7RWfCxw==
X-Received: by 2002:a1f:a097:: with SMTP id j145mr17074369vke.18.1558559831199;
        Wed, 22 May 2019 14:17:11 -0700 (PDT)
X-Received: by 2002:a1f:a097:: with SMTP id j145mr17074327vke.18.1558559830353;
        Wed, 22 May 2019 14:17:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558559830; cv=none;
        d=google.com; s=arc-20160816;
        b=Jtzcog6m5Q4oR9pxUl0RUWYPXTXqTHhm15tEfv6Xt68KQ1WZ4D/8vr/YKkPXzvtcPl
         4NFzG3T8YBWMiZqhiHz/0Ar5u4fc9P0z5DL/xLmJDjUl0JX+1xpNgJeh+RrfB4MVGK/P
         6MD2f3QFyGhyO2nEyHQEc8E7zxLtm1h+pQC1DDh5VWimAAt//aiMnXjncKJfBTmVKUJW
         HbZrMqb36yyBCi5Q7LOD659bbN8wUrdnF/YEwMn+whmRNXh47LpnA7JNfHzW5MNz1bWv
         TJXR5Pw3VLfnzYYadwz6bqFLbDJaKvetUU2HwNaAmmnlLWu//PooJ96OyPQwto9o8uu9
         vljQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4dHniiz5Iec+zX/39XStbUXbmPxCKmuaK7gygHepfyc=;
        b=N3O2nOw0vsm8QMeHKoR5+Ab3NDuyX9tfodlpDyu3sayJNqdyd+48p3b794Cqri1DS2
         g4mtK22x6pjnsdq2FwXF2wivQhY+UtbYj3f/inuvKuqYtrX4p6szpxTsU+v+t5NaZIhx
         9Z7MngQjwBK/96FlqW9yiABWA6bpdNLS+lW5Klj8wd/1SOOxvGw6+MOepUtDuOTGwD/V
         wBJH7P+59Z2YL6nV9p0VtbPi+5qFEzYdYsOj9af029QvQumrqeXv3q0g+yPr4RTWAxO6
         3jauzgzwqj/IuFFhewuW/PmJXgpiNlyNikghEpP5IZDKbdhl2NyOjkzj+29IlHZojw6c
         aYig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BozsRedf;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8sor4282848uao.16.2019.05.22.14.17.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 14:17:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BozsRedf;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4dHniiz5Iec+zX/39XStbUXbmPxCKmuaK7gygHepfyc=;
        b=BozsRedf7hxOrPEwc14/5gYKjPtcuYPfCzdL5Qh8eptxMopndG6sl6KK8l1wx0gHcO
         fX9KUGo72jJQy2d1m1wZ3No1Qi2uQpl1cB2uKNXeTTE0y7bVHQRp3jZ8gNy6f12oUbuZ
         9pqndA18D5HuCzEP7FakfNMcFjkFYSW5Qf6tTdWeb6YU5HYx7NFV4gOPaqZKnmwkQ5VN
         K2fCVmPCADr0j8VP+wLoOUFpEpW6WISMm8/ajD25DfdGIBy1SiKGnwF+/Lt+nHE51rtB
         vS7fbs1gYfPlwpTBaswd0RKzwzIK+7d4NhNx6dxPb1W6jd5YUGLoFQyi73p/mW3CKcJq
         v2ig==
X-Google-Smtp-Source: APXvYqxH4+lXdvKeAKR6IcV6qRcWyD41x0RLMgowdC0uvePb1uyY7QqZdIceH4zhHD2Gn25pj1INm9uTZm6L2qnPIh8=
X-Received: by 2002:ab0:115a:: with SMTP id g26mr16507991uac.84.1558559829704;
 Wed, 22 May 2019 14:17:09 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190522114910.emlckebwzv2qz42i@mbp>
In-Reply-To: <20190522114910.emlckebwzv2qz42i@mbp>
From: Evgenii Stepanov <eugenis@google.com>
Date: Wed, 22 May 2019 14:16:57 -0700
Message-ID: <CAFKCwrjyP+x0JJy=qpBFsp4pub3He6UkvU0qnf1UOKt6W1LPRQ@mail.gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 4:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > This patch allows tagged pointers to be passed to the following memory
> > syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> > mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> > remap_file_pages, shmat and shmdt.
> >
> > This is done by untagging pointers passed to these syscalls in the
> > prologues of their handlers.
>
> I'll go through them one by one to see if we can tighten the expected
> ABI while having the MTE in mind.
>
> > diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
> > index b44065fb1616..933bb9f3d6ec 100644
> > --- a/arch/arm64/kernel/sys.c
> > +++ b/arch/arm64/kernel/sys.c
> > @@ -35,10 +35,33 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
> >  {
> >       if (offset_in_page(off) != 0)
> >               return -EINVAL;
> > -
> > +     addr = untagged_addr(addr);
> >       return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
> >  }
>
> If user passes a tagged pointer to mmap() and the address is honoured
> (or MAP_FIXED is given), what is the expected return pointer? Does it
> need to be tagged with the value from the hint?

For HWASan the most convenient would be to use the tag from the hint.
But since in the TBI (not MTE) mode the kernel has no idea what
meaning userspace assigns to pointer tags, perhaps it should not try
to guess, and should return raw (zero-tagged) address instead.

> With MTE, we may want to use this as a request for the default colour of
> the mapped pages (still under discussion).

I like this - and in that case it would make sense to return the
pointer that can be immediately dereferenced without crashing the
process, i.e. with the matching tag.

> > +SYSCALL_DEFINE6(arm64_mmap_pgoff, unsigned long, addr, unsigned long, len,
> > +             unsigned long, prot, unsigned long, flags,
> > +             unsigned long, fd, unsigned long, pgoff)
> > +{
> > +     addr = untagged_addr(addr);
> > +     return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
> > +}
>
> We don't have __NR_mmap_pgoff on arm64.
>
> > +SYSCALL_DEFINE5(arm64_mremap, unsigned long, addr, unsigned long, old_len,
> > +             unsigned long, new_len, unsigned long, flags,
> > +             unsigned long, new_addr)
> > +{
> > +     addr = untagged_addr(addr);
> > +     new_addr = untagged_addr(new_addr);
> > +     return ksys_mremap(addr, old_len, new_len, flags, new_addr);
> > +}
>
> Similar comment as for mmap(), do we want the tag from new_addr to be
> preserved? In addition, should we check that the two tags are identical
> or mremap() should become a way to repaint a memory region?
>
> > +SYSCALL_DEFINE2(arm64_munmap, unsigned long, addr, size_t, len)
> > +{
> > +     addr = untagged_addr(addr);
> > +     return ksys_munmap(addr, len);
> > +}
>
> This looks fine.
>
> > +SYSCALL_DEFINE1(arm64_brk, unsigned long, brk)
> > +{
> > +     brk = untagged_addr(brk);
> > +     return ksys_brk(brk);
> > +}
>
> I wonder whether brk() should simply not accept tags, and should not
> return them (similar to the prctl(PR_SET_MM) discussion). We could
> document this in the ABI requirements.
>
> > +SYSCALL_DEFINE5(arm64_get_mempolicy, int __user *, policy,
> > +             unsigned long __user *, nmask, unsigned long, maxnode,
> > +             unsigned long, addr, unsigned long, flags)
> > +{
> > +     addr = untagged_addr(addr);
> > +     return ksys_get_mempolicy(policy, nmask, maxnode, addr, flags);
> > +}
> > +
> > +SYSCALL_DEFINE3(arm64_madvise, unsigned long, start,
> > +             size_t, len_in, int, behavior)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_madvise(start, len_in, behavior);
> > +}
> > +
> > +SYSCALL_DEFINE6(arm64_mbind, unsigned long, start, unsigned long, len,
> > +             unsigned long, mode, const unsigned long __user *, nmask,
> > +             unsigned long, maxnode, unsigned int, flags)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_mbind(start, len, mode, nmask, maxnode, flags);
> > +}
> > +
> > +SYSCALL_DEFINE2(arm64_mlock, unsigned long, start, size_t, len)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_mlock(start, len, VM_LOCKED);
> > +}
> > +
> > +SYSCALL_DEFINE2(arm64_mlock2, unsigned long, start, size_t, len)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_mlock(start, len, VM_LOCKED);
> > +}
> > +
> > +SYSCALL_DEFINE2(arm64_munlock, unsigned long, start, size_t, len)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_munlock(start, len);
> > +}
> > +
> > +SYSCALL_DEFINE3(arm64_mprotect, unsigned long, start, size_t, len,
> > +             unsigned long, prot)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_mprotect_pkey(start, len, prot, -1);
> > +}
> > +
> > +SYSCALL_DEFINE3(arm64_msync, unsigned long, start, size_t, len, int, flags)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_msync(start, len, flags);
> > +}
> > +
> > +SYSCALL_DEFINE3(arm64_mincore, unsigned long, start, size_t, len,
> > +             unsigned char __user *, vec)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_mincore(start, len, vec);
> > +}
>
> These look fine.
>
> > +SYSCALL_DEFINE5(arm64_remap_file_pages, unsigned long, start,
> > +             unsigned long, size, unsigned long, prot,
> > +             unsigned long, pgoff, unsigned long, flags)
> > +{
> > +     start = untagged_addr(start);
> > +     return ksys_remap_file_pages(start, size, prot, pgoff, flags);
> > +}
>
> While this has been deprecated for some time, I presume user space still
> invokes it?
>
> > +SYSCALL_DEFINE3(arm64_shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> > +{
> > +     shmaddr = untagged_addr(shmaddr);
> > +     return ksys_shmat(shmid, shmaddr, shmflg);
> > +}
> > +
> > +SYSCALL_DEFINE1(arm64_shmdt, char __user *, shmaddr)
> > +{
> > +     shmaddr = untagged_addr(shmaddr);
> > +     return ksys_shmdt(shmaddr);
> > +}
>
> Do we actually want to allow shared tagged memory? Who's going to tag
> it? If not, we can document it as not supported.
>
> --
> Catalin


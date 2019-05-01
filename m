Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C021CC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 20:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73BD520656
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 20:32:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="mzKRQByx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73BD520656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CFE46B0005; Wed,  1 May 2019 16:32:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0806D6B0006; Wed,  1 May 2019 16:32:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB1176B0007; Wed,  1 May 2019 16:32:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC8B6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 16:32:44 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so84828edz.3
        for <linux-mm@kvack.org>; Wed, 01 May 2019 13:32:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QL2tBN3pQ9dGG9oKQvnxrcR2IX/vPQNIJ81izHaCYVE=;
        b=QEbdL7Y+yXXh8hAnFAoAOFt1sR3N3JedEjXDWp8pVxV55IXeOlQ1Xb06sx7lYRDiD6
         79oE5vKzRU7565lwbqJoYG4zAOjNeSDD0COgVRXC91wkCymjecCjfMBcOqnfmGYk2cjo
         51deS7UnVrq1mRx6RCYDLrePExTYqgBKQZ09TUjUKl0aYw2J8YhnwRUZ6myjZ56Z0GaU
         xzDNTjPjvugzLrRekOeTKHj9zjJIWIXCMc1XxSI67kcPfXdcKiBO01G2w2Em5xWIIAWi
         5AaF+nUzLYkSbGCPCfbnq7Z2o3lUoFNROseqJR31RVB3r+a+tpFZ1iwhjolQdWVjecx/
         WvkA==
X-Gm-Message-State: APjAAAVwSWvRx7ccmCaTB/jys8zKgsZhFeQP6HwVdQ5CJYidbVzOZ3DD
	cPFO/uSyAXRP1mHssDpghQ4LkFys1knYSD1z9+lPvHD0MPsb9fLsqd+S9THFNLBN7Hlf+QEsreQ
	L/FfXNpgK+Vit2n8JiayIPSAIK/J/ct4Bls9YExePhpfSTT71E3UvlEHaM2xabolctQ==
X-Received: by 2002:a50:cb4d:: with SMTP id h13mr113281edi.110.1556742764100;
        Wed, 01 May 2019 13:32:44 -0700 (PDT)
X-Received: by 2002:a50:cb4d:: with SMTP id h13mr113254edi.110.1556742763370;
        Wed, 01 May 2019 13:32:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556742763; cv=none;
        d=google.com; s=arc-20160816;
        b=CpUgEiyMAbOkqSBFvF7H9uMdA16Cgz14mBglZx87SAhx3DCVTe2uDlM3sRYnc+5n+D
         JLD4lxFNwTlpslPXCH/BpyyRlCOKzlg8YGe2xGfCDc+4ujwR14Ql+VQ5a/+WfEkbyxgG
         dpc29vBAWuQFvSFv+AK0lVFh5IVn01NQBYZ69k4etcubY/gzkQVf6gNQo6UJ9/mVNCBL
         I8Q/l2M3M2PwZKXofnRcjnFgy1f+W64dKwvIuxePWQT2De1+cokZdbnqVmCPFPoteHu6
         uUnVI4RiAkHZbXkW0f1BRNqtO2/7GATkrPcdrLZBa2cGK1J06lNm+9XsJuHIQ2EAGn3K
         3u+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QL2tBN3pQ9dGG9oKQvnxrcR2IX/vPQNIJ81izHaCYVE=;
        b=fA54VS2wOZcrqVMqvPbDt5UwoffnkW6ohVqDWCv814uqOZP7b9+JoYbSslAMvLvtnu
         x4kT671F16q8XBlvK5K/DDHDSS93k+i0PssWvGiJJcXsU9onNoccigZxUSF5mp081LwY
         DHbF1EnO3Kb+i0Qgf4qxhFBsoNQv1ukZYypQ/dI4BvAq56pSRpZiPhuvd2wqcFFhSulA
         4hSjJw6qZIGd/AGcs7pT+tmxth1ucIt39hqSqopqyX9T5j55TLcziVNqEg66UfLlZ0ar
         6ruxJ2f5A8AqjZFZAdbOyHWlx2RPAmzmltjOWmDyIALQHIcRz0pjRifbnX9NuItdebIu
         veFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=mzKRQByx;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i6sor14461108edd.12.2019.05.01.13.32.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 13:32:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=mzKRQByx;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QL2tBN3pQ9dGG9oKQvnxrcR2IX/vPQNIJ81izHaCYVE=;
        b=mzKRQByx0s0KuJiv923WITWkB8HGSQ8iB2Vm0yGys+DRqZ7u+jZE+I0J9Sf31Vv/HO
         +h2hzwvWGwheD6omUYoJ1ESvw9Fzo6a3Ssvy89DI3Nhu+qjEMb5MRP1k1YyVUOSimlci
         LYJvAFAe01WkHwC15kmNdYbBXx8UhFuJqH2ymIPVu/300rR/NimAwD0tyuJXDd6YM0nA
         OfTzGh1x0BHXeTxdCwF3KP6W98HHsBd18S1eRxsyFJRyjEpR+TFFVITJahbCBetmp5yy
         INuzAxNCDCuSdNJDldkEICwniz80FC+AtvUzslsTAgbqhLq+IG9X94eHJutZGUOdrqU7
         /ong==
X-Google-Smtp-Source: APXvYqxG+zywxchpt42VU6VUd0dsOC2Chj0pTVZjpYpEIuN415/v9h1x2i3BVmepMqcB8yJtyEdO/62sRk0+pKJlEL8=
X-Received: by 2002:aa7:cf8f:: with SMTP id z15mr110045edx.190.1556742763007;
 Wed, 01 May 2019 13:32:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190501202433.GC28500@bombadil.infradead.org>
In-Reply-To: <20190501202433.GC28500@bombadil.infradead.org>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Wed, 1 May 2019 16:32:32 -0400
Message-ID: <CA+CK2bDAPuXcDewb+Q--VWuDUGhzvufHRwZmh1=tuaOUMJfsMw@mail.gmail.com>
Subject: Re: compound_head() vs uninitialized struct page poisoning
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 1, 2019 at 4:24 PM Matthew Wilcox <willy@infradead.org> wrote:
>
>
> Hi Pavel,
>
> This strikes me as wrong:
>
> #define PF_HEAD(page, enforce)  PF_POISONED_CHECK(compound_head(page))
>
> If we hit a page which is poisoned, PAGE_POISON_PATTERN is ~0, so PageTail
> is set, and compound_head will return() 0xfff..ffe.  PagePoisoned()
> will then try to derefence that pointer and we'll get an oops that isn't
> obviously PagePoisoned.
>
> I think this should have been:
>
> #define PF_HEAD(page, enforce)  compound_head(PF_POISONED_CHECK(page))

Yes, I agree,  this makes sense.

>
> One could make the argument for double-checking:
>
> #define PF_HEAD(page, enforce)  PF_POISONED_CHECK(compound_head(PF_POISONED_CHECK(page)))
>
> but I think this is overkill; if a tail page is initialised, then there's
> no way that its head page should have been uninitialised.

Also agree, no need to check head if subpage is initialized.

>
> Would a patch something along these lines make sense?  Compile-tested only.

Yes, I like the re-ordering PF_POISONED_CHECK()s to  be before the
other accesses to PPs.

Thank you,
Pasha


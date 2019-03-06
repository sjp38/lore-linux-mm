Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01785C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B23A4206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 10:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B23A4206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4317E8E0003; Wed,  6 Mar 2019 05:27:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E0BD8E0002; Wed,  6 Mar 2019 05:27:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F7AD8E0003; Wed,  6 Mar 2019 05:27:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02B7A8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 05:27:08 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id e1so10894412qth.23
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 02:27:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=CSeOuhnVpG+O/XMLRISqa+zO/p/JxBsd2lVZegfOtAE=;
        b=pg1E3JB+TY4IuAYxC2d2Y+dNKrFoO42hreNoo8Yez47/Inj+z51scOqASSkBkjujjs
         QkSFYFen6GFJypzkJt49H/McAzOd3WI4RcWkEAuMEItATuZPgpUlvBisrJ6hBtRwbJg3
         exvhTD8cN5bSDQdfsBysC8LH/1FNe02hxIJNO0ZkotMKP7KKn5f7pHg4WzKwvtItugt5
         hF0LLBe1nD/pjbzJGI5hPCrbRM/CdkS/VFVZgfyxSs+ZxwJ4Dm7zxSJl/1IYV2BJaIFB
         0fHyN1y/cev1bLMsVo3VMB3uzwGfv3CzTLBhR3J6jY/gE6/nhmlkEmPOLFeVizkFJnPA
         6HSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAXMs+cdshrZBou9ga5t31QSdYozBKH9utIcNiPPtnnhZZHXHBqk
	paumoiOc1t3n0eAHauP4c9r3ufsVRSD6bne/k8jjrTSqOj/G4IfyHBGL8PDvzcDol0IFc7h4drH
	y4WCg9BnUbJhnj3Kwnn9wtW9POtSBzykraOgOGKS+4eFFAfakjNFJvWpaRf5FytJnlfDlweh9dy
	hgxwWrML6q028vjYi/CwH5RHYKBR0aiLpQcpbN5gT4rpfvvnVpMUE/p4YPFu/TkauBBF6NyPdlw
	0DC4NXiGJwzffZOthH8upk0eNq2YvW32DAeSf5zMKqQ/NbO0Ue4qJ0F9VJoeJGybiYmtuJdUYiy
	cwxGy5uT9wa07oN77f1Em20d+5R0LAhdXU33VkyjFeX1CJNPIZlPp9TbMUyervlEOfVj2jakJQ=
	=
X-Received: by 2002:ae9:e702:: with SMTP id m2mr5243247qka.279.1551868027770;
        Wed, 06 Mar 2019 02:27:07 -0800 (PST)
X-Received: by 2002:ae9:e702:: with SMTP id m2mr5243224qka.279.1551868027179;
        Wed, 06 Mar 2019 02:27:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551868027; cv=none;
        d=google.com; s=arc-20160816;
        b=bp8VSXJnfQluG2MdCMZELscfHpumibHjhajeLPpHx5cKIvniMgUrG95Ww/xdWu6PE8
         Y8FlsBDJ6iYVjlC2IX7BCMfbQIySBvw/WTLAZdOwvQVF5JWJVqXj6HGNacSJzfjatjor
         4el+QuQHBGgbhMYC6wU5rbyMV3fk0WWNis9WqdX86Ag3TClsynLg1or3WlEEUZYf9DBx
         Z+85HjwUxhVCHMv3wNKyinrf5HufTq7t2voH+jfTggedePsJcmUChLhett0D8BGRxeer
         MHajmbyQ6uNKNmf5vVSmY7qQY/G/DZz6hPQObQHNWnXEnHPDQUHeeXZGZqdLXmkhrHl9
         K/Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=CSeOuhnVpG+O/XMLRISqa+zO/p/JxBsd2lVZegfOtAE=;
        b=dABgOuUgLrV/yPjO3UxebikEJ3Gt3pHLYD8I1ZGCttMdqUw3nmi1qCarB0821RtdHN
         ilqznFz9VQJEjQfFuU31mqhlUueZ5zCvXB/LN7xvOkSt1VbEfe4p3fw4pRBpaRmRRLL8
         HjoUIvegnxjiC1bWK8cHNce8QQluQJ4+ukWcpAMufiKBBJjW/BcH2KWLa0TMY/aSE6yv
         0RLZ6oxe2eXPMBK4zjSmxGuDy/8fwKQVPD7pCBOliyhxdU2bZ2kEkyh5HLvSOUgOjrXw
         qPzdCzsc8SxsfaN2w3uLcwwNkSQI9AQG+4DIhDvtbahdu4WxMIo4QFZTo5t/rim+iKBU
         LU9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q22sor1272724qve.3.2019.03.06.02.27.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 02:27:07 -0800 (PST)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqx8KXF2sVH+kCoN66rCFdIhCx5S1tAN7BNbc9XkL0WASGOtHPlJRmgDHIyw4pXWTxuHzbi+XfPwGYdOq6NGtk4=
X-Received: by 2002:a0c:b501:: with SMTP id d1mr5728256qve.115.1551868026847;
 Wed, 06 Mar 2019 02:27:06 -0800 (PST)
MIME-Version: 1.0
References: <20190304200026.1140281-1-arnd@arndb.de> <be817f74-3441-47c1-6958-233d6e1172c4@arm.com>
In-Reply-To: <be817f74-3441-47c1-6958-233d6e1172c4@arm.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 6 Mar 2019 11:26:49 +0100
Message-ID: <CAK8P3a3FUtGceVWK530E-iOWqh=p=Q-KKZCkNCeXh2UhFc3m9A@mail.gmail.com>
Subject: Re: [PATCH] mm/hmm: fix unused variable warnings
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, John Hubbard <jhubbard@nvidia.com>, 
	Dan Williams <dan.j.williams@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 5, 2019 at 1:18 PM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
> On 03/05/2019 01:30 AM, Arnd Bergmann wrote:
> > When CONFIG_HUGETLB_PAGE is disabled, the only use of the variable 'h'
> > is compiled out, and the compiler thinks it is unnecessary:
> >
> > mm/hmm.c: In function 'hmm_range_snapshot':
> > mm/hmm.c:1015:19: error: unused variable 'h' [-Werror=unused-variable]
> >     struct hstate *h = hstate_vma(vma);
>
> After doing some Kconfig hacks like (ARCH_WANT_GENERAL_HUGETLB = n) on an
> X86 system I got (HUGETLB_PAGE = n and HMM = y) config. But was unable to
> hit the build error. Helper is_vm_hugetlb_page() seems to always return
> false when HUGETLB_PAGE = n. Would not the compiler remove the entire code
> block including the declaration for 'h' ?
>
> #ifdef CONFIG_HUGETLB_PAGE
> #include <linux/mm.h>
> static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
> {
>         return !!(vma->vm_flags & VM_HUGETLB);
> }
> #else
> static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
> {
>         return false;
> }
> #endif

The is_vm_hugetlb_page() check is unrelated to the warning here,
the problem is that huge_page_shift() is defined as

#define huge_page_shift(h) PAGE_SHIFT

when CONFIG_HUGETLB_PAGE is disabled, so after preprocessing,
the only reference to the variable is removed.

     Arnd


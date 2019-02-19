Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B246C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 22:28:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 089C02083B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 22:28:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R3OKPtUj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 089C02083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64DCB8E0003; Tue, 19 Feb 2019 17:28:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D4B58E0002; Tue, 19 Feb 2019 17:28:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44E818E0003; Tue, 19 Feb 2019 17:28:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 161158E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 17:28:33 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id q141so7101189itc.2
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 14:28:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BKRd5AyyK61scsjgCwEIyTQj0eRdMqLiIZW6sZLtvKI=;
        b=MbfSvbJFcR7st89keUJm42ixrDT76lMOZT7IwuWKl+YKE6C+T+o6XDb30WLYZWCxoY
         pGOo+603pcoLF03lNabsVIp63Qb2QEOk5P0BCfpwEIp3GeBYFKUCDqWmGP5y7cjdq/s/
         Io7O1u6ViTu6PRchmhkmso+TjAojFyzxo8hOCKEOg22EODXDtTL7g3c9frTTw9sh9x7e
         Ol14ltGVHiICJBQutSQpr3URq3Aaek02/AATMKzKtCTIwFtVtqunSt19ymQhyUw2NyNz
         2kwnJ73q1l4QWug6SquAcIf2BhblBvP5uXUQXPlkzQr1VF/DacIhlOG/8fEEEWyNq5dr
         jMWQ==
X-Gm-Message-State: AHQUAuZByYJB40Gyub4wRnUdsvD+bglV8ITA9nBAsdcCI+wj6yMd4a7m
	RVRbiNgOLQaLpAEAQiSLdCsTLJkbWmJTaNKrsah6WluJyfQTe3FFBErj6Wp3Dyw8PI5tnneAO8T
	3euswSuOW6MGDsPThRCAxBjXRa91kM73SJdzU0k8FmLcOF58I7r+hNQfKq2s7L6cv0+9KgLuTz2
	o5/nB2d8aRvlGsdVFAqYbOCsgfiaxySrb600+MoKhC9Z0HuYi/jwotyLU88S3K54HIE5fQUsqLR
	+HyxjmXtKtingCjMot5KMXP7bOaVA0t21off2YC4qRM1aYRLTzngEuq04uSBRQIUApI+wLCQoGj
	vRDU40cnDs5r6nc7dddL/LEDcpbsHKjZbE2V6D6oB6EsmJaAWt1SC8fWAnRwIztIXSJ1KeCX9t7
	q
X-Received: by 2002:a02:9d05:: with SMTP id n5mr17468909jak.53.1550615312789;
        Tue, 19 Feb 2019 14:28:32 -0800 (PST)
X-Received: by 2002:a02:9d05:: with SMTP id n5mr17468870jak.53.1550615311871;
        Tue, 19 Feb 2019 14:28:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550615311; cv=none;
        d=google.com; s=arc-20160816;
        b=EWwvIdSj0QffXFs7wik8U53aAc503U+rS3oY7lLpN7QxoG5TiOed+Whlh++JyNa0zx
         TziU6k0PLnc26iMb/mR1Sn+xusbzxMyOO7doeKRelyQw7W9XnmxlJC/dzXzo49izj9CE
         JJpaSeFVKteWBlzJJWcn51yFGxl8RNG/XgE/b5CivODmYyxR34Ggl0TTRB5FdVUJ+eHg
         eKEYjHccdxpqFt15SpiVge+E4LQh3mUGKtPbz9N5Hl5DRwETBmGMFk2fM/cNYtItJ6GS
         hCawDgcEFApCUvngqfSu/ITcMHIs2gLRxqfTgZNyFJVycPE3f1URrCEupZvLEVhMOiEB
         OOOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BKRd5AyyK61scsjgCwEIyTQj0eRdMqLiIZW6sZLtvKI=;
        b=GKkAZwFL5QoE1KzQv/loTPtfxz6LVWK8jT+O9Y+6jXUMJxb2gUwHKwFIYltmJuKhRB
         X6xUPLFxRARaoAx9Csa/qApu4IJo5L3baozmJEKyF+/Az6bFdxc2Bn+NjINAI3buMKoX
         IQ4qnePNIB6454oD7CTKxnqjY3Twg8KiXXZR3/vvy2WNzzf/nayhJHR8q1lR1NZ5VkxA
         CA2aTk8BcKVn5MJhbU7GxfuiZAXjn+e1icCNxmhdEIfyBiO0YVz8muIu4LwtjorE/WE+
         mfC3gyuneIiht9pduHIp1zA8uV/ijG13drDBvC+fy5Q7mYiaJGk1g+4XBn7Y1EQh+wxZ
         99oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R3OKPtUj;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f190sor6491697itc.14.2019.02.19.14.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 14:28:31 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R3OKPtUj;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BKRd5AyyK61scsjgCwEIyTQj0eRdMqLiIZW6sZLtvKI=;
        b=R3OKPtUjdUCZIw87Ibh7o6aDdAs0vzWVIYWa5QAOcfBzDwH9bZwB+EMnz4kD8GjLlO
         byuTLz068rv/8UpFmomNkA4F4LazeVxgTT4/8YauHoiHT/N30hqQyGyrqRq7lP839w1Z
         xyDCyrTEk6k5IAPeXlsi0VIkvd/U3VBXp1IW4pQqwjy4zV/sX62Y1Pu9oKWITE2S6JII
         HrAjqloWBN8iimotuNw6TR/VjQUi+wWOEX6ZyU1BioayAjydUtOWhh9SA6Z0o6n8tEEg
         16JWBcqysj262OGcUGjZX+euq4nF0UxoMkEep/xaEeg9hHjDGaDpqUi0VdnoWZRHfscJ
         OxZg==
X-Google-Smtp-Source: AHgI3IYDrRq/fljAVOdA83+8pvwWb7QsvvWaKeFJSwJZsRzEaSegd5cU0sMDfnBu0WjxoCa4wTZy0w==
X-Received: by 2002:a24:9d81:: with SMTP id f123mr4298178itd.55.1550615311324;
        Tue, 19 Feb 2019 14:28:31 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id t5sm6916976ioi.43.2019.02.19.14.28.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 14:28:30 -0800 (PST)
Date: Tue, 19 Feb 2019 15:28:28 -0700
From: Yu Zhao <yuzhao@google.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190219222828.GA68281@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
 <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 11:47:12AM +0530, Anshuman Khandual wrote:
> + Matthew Wilcox
> 
> On 02/19/2019 11:02 AM, Yu Zhao wrote:
> > On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
> >>
> >>
> >> On 02/19/2019 04:43 AM, Yu Zhao wrote:
> >>> For pte page, use pgtable_page_ctor(); for pmd page, use
> >>> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> >>> p4d and pgd), don't use any.
> >> pgtable_page_ctor()/dtor() is not optional for any level page table page
> >> as it determines the struct page state and zone statistics.
> > 
> > This is not true. pgtable_page_ctor() is only meant for user pte
> > page. The name isn't perfect (we named it this way before we had
> > split pmd page table lock, and never bothered to change it).
> > 
> > The commit cccd843f54be ("mm: mark pages in use for page tables")
> > clearly states so:
> >   Note that only pages currently accounted as NR_PAGETABLES are
> >   tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.
> 
> I think the commit is the following one and it does say so. But what is
> the rationale of tagging only PTE page as PageTable and updating the zone
> stat but not doing so for higher level page table pages ? Are not they
> used as page table pages ? Should not they count towards NR_PAGETABLE ?
> 
> 1d40a5ea01d53251c ("mm: mark pages in use for page tables")

Well, I was just trying to clarify how the ctor is meant to be used.
The rational behind it is probably another topic.

For starters, the number of pmd/pud/p4d/pgd is at least two orders
of magnitude less than the number of pte, which makes them almost
negligible. And some archs use kmem for them, so it's infeasible to
SetPageTable on or account them in the way the ctor does on those
archs.

But, as I said, it's not something can't be changed. It's just not
the concern of this patch.

> > 
> > I'm sure if we go back further, we can find similar stories: we
> > don't set PageTable on page tables other than pte; and we don't
> > account page tables other than pte. I don't have any objection if
> > you want change these two. But please make sure they are consistent
> > across all archs.
> 
> pgtable_page_ctor/dtor() use across arch is not consistent and there is a need
> for generalization which has been already acknowledged earlier. But for now we
> can atleast fix this on arm64.
> 
> https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com/

This is again not true. Please stop making claims not backed up by
facts. And the link is completely irrelevant to the ctor.

I just checked *all* arches. Only four arches call the ctor outside
pte_alloc_one(). They are arm, arm64, ppc and s390. The last two do
so not because they want to SetPageTable on or account pmd/pud/p4d/
pgd, but because they have to work around something, as arm/arm64
do.

> 
> > 
> >> We should not skip it for any page table page.
> > 
> > In fact, calling it on pmd/pud/p4d is peculiar, and may even be
> > considered wrong. AFAIK, no other arch does so.
> 
> Why would it be considered wrong ? IIUC archs have their own understanding
> of this and there are different implementations. But doing something for
> PTE page and skipping for others is plain inconsistent.

Allocating memory that will never be used is wrong. Please look into
the ctor and find out what exactly it does under different configs.

And why I said "may"? Because we know there is only negligible number
of pmd/pud/p4d, so the memory allocated may be considered negligible
as well.

> 
> > 
> >> As stated before pgtable_pmd_page_ctor() is not a replacement for
> >> pgtable_page_ctor().
> > 
> > pgtable_pmd_page_ctor() must be used on user pmd. For kernel pmd,
> > it's okay to use pgtable_page_ctor() instead only because kernel
> > doesn't have thp.
> 
> The only extra thing to be done for THP is initializing page->pmd_huge_pte
> apart from calling pgtable_page_ctor(). Right not it just works on arm64
> may be because page->pmd_huge_pte never gets accessed before it's init and
> no path checks for it when not THP. Its better to init/reset pmd_huge_pte.

This is not the reason. Arm64 gets by with calling
pgtable_page_ctor() on pmd because it only does so on efi_mm. efi_mm
is not user mm, therefore doesn't involve thp.


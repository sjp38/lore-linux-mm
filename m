Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6982C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 20:48:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BFE62146E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 20:48:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NUQUzfw8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BFE62146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 131E48E0003; Mon, 18 Feb 2019 15:48:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E1968E0002; Mon, 18 Feb 2019 15:48:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEA448E0003; Mon, 18 Feb 2019 15:48:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C82908E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 15:48:47 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 135so716891itk.5
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:48:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/NLpiy+j/zrpP+sVhQdIcgCVfL0HwEex4aRdsJ4vY8Q=;
        b=CRiOZRzRI7lic+lHenqm11GkdHZPpNpopOomiFHcLnJeqHronVofX0W2gTBfd17Bsm
         RpBqOyFnhhIDozp3o5bBE0+TyZuqLrlPE0nONrfhdjX1pd3v+OojAtLiLXNean+vs70I
         qX+L/aR3te3cA1ZK3DTjeAECjHrA3nqZrPYIHGN0o8FUgUFtGd+WcnI8h0kNuMgZn7rq
         hIwTBQbNZ87hgKXKMBpZ3LdZK3Dv0SzO+tCtYoagKoCtn9eEuzN3yjcb1Ub9xqfRk76E
         2Q1upa+0WVW1Vk+0dVaSXifdGLHjkew6ProrL8h084jmpAzWKHK8QzYZuuuFjyFpP4mQ
         xy+w==
X-Gm-Message-State: AHQUAual/1+CBFyB9yB2ZOgFr1glnEsJdhUVp4a3hWMvFXHaaBGgBCj4
	/WkNHVwCyZJ6U27VmzlHpYFR98actpKe9j8hADKdkd5SqwUlLTQ9TtN8yxeTGfRzFqPn7HxhotL
	NHpGJwV3PMRtb8/wZNDStDluPK+pGX0i3i73TQzhqpDT+95vxIRNantHLTZ6ZSJhUMYie1TR7YS
	1xtiLK6TbdwrgEXZjn/YCgrKkfikXDgwL6LezwB6n1IwKeMkQ41BRpotiaKX7b5zrKom+zWDkf8
	ULWXQAAkQ2BK5GyYXFJKRcnrqF+g2B20jhmx6Iy/WMjHrpknQlbPjWHwIdtV0hdgvxdFGOwPOyE
	cmVOTMJh9Xf1XXu81wFe3/7R78jM4gqdA9k2MVi0iRNbrHMMVfEjLvmC9OnJWzJ+dPQnK5mHjj+
	x
X-Received: by 2002:a6b:500a:: with SMTP id e10mr13500091iob.127.1550522927502;
        Mon, 18 Feb 2019 12:48:47 -0800 (PST)
X-Received: by 2002:a6b:500a:: with SMTP id e10mr13500046iob.127.1550522926432;
        Mon, 18 Feb 2019 12:48:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550522926; cv=none;
        d=google.com; s=arc-20160816;
        b=iByUJB8X++Y/7H3nYeKdMA+z+Xfc74xTdg3Rb06mANourOCr+eQ9tv8vhNVTPn/Eyp
         CulSg7OTrTD3I0pgPlNS/43CX6Y9cZO6v4sjNi3Af7pqGpWMbgA6aJARDQQxk3piue9F
         qMK/PFIwZDzWHHEwyh/HAy0Mka0CL2b+We1XTo7j9Saes80KTygNU7mekuHUz42R/yMK
         guATiE+D/6Wy/IlpvbkXZhMqxxjZ+zFBzxibnTrzTlps0Ukm/xRzb0p3bHsRDPwguwvW
         PVDjq889XmFbhyNNrrGfB/aRJrdtPlTUW2Nm/SOgNZdYCkzunIQkCV0kxGe/eG8etacU
         Pf/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/NLpiy+j/zrpP+sVhQdIcgCVfL0HwEex4aRdsJ4vY8Q=;
        b=KwICQ+VArD3fh+7iUQoLBLd7NhfACvci3JeqrAcSU99YwnLi2bh+4tPqur11yukHXZ
         JVxO355Pq9uVY0v5gu4voDGZ3q+XrD7VFZkj5DkA1osy9n9hGlEFTHBv/MysPpTR7GVE
         H9QAoYJOHOP3v291fsVy1ongdeb667Ub5cbcPucladqFZWtGv7PDWvMCjz0oQRU4t78y
         yOKYCk4WKq9ryvPXO4gxfyOD2SEdgpSFiGfhYSB0gaiVvvwlElYX+k02uc+96sI06E3R
         +xh/rsiwXS4GyQkVcRoxyMhrTbVhu9jhViGivIbR3XwHW46LSaPYE8mjTbwdZjF0cguM
         Tm0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NUQUzfw8;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j187sor735982itj.27.2019.02.18.12.48.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 12:48:46 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NUQUzfw8;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/NLpiy+j/zrpP+sVhQdIcgCVfL0HwEex4aRdsJ4vY8Q=;
        b=NUQUzfw8/x7dr0Q70sqUQawAGRy1k43ldVFkm4ZbYxr1A3YdpzcGBs+YvYXIOhmZr+
         45UfT9cky6fpnR0KZOUXAxs90kZDwfEffomg1cwN/PpVg0WEPS6aW5GpHLtuct5JMUJq
         K213WVXJIDZ0l/iI9bu25oOyzAcMIFxP79Nzr9hkj/tZezv0NOLTYFZ9AnOC59poJK9q
         21/h5HJxE20vXVmiNlzp3I8scZNb5ELd+yb3+OnbaSox94ydiQ/+kUattnzPon/0+iDL
         dldi9AiGX42H8k9DyNw8FdUIZITG8BoFgW4sWn7w7K/aJ6rwcJ5lSHZ1Wj1Iso7Z53Ba
         dSvA==
X-Google-Smtp-Source: AHgI3IYoW571J1Mbargry0dSLvhBvQdK5/NeOan6qv4n/bRuaI5i5jinvq0JPQkH5R/r3DLUERBiXg==
X-Received: by 2002:a24:4648:: with SMTP id j69mr470647itb.56.1550522925849;
        Mon, 18 Feb 2019 12:48:45 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id d6sm5943432ioc.44.2019.02.18.12.48.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 12:48:44 -0800 (PST)
Date: Mon, 18 Feb 2019 13:48:42 -0700
From: Yu Zhao <yuzhao@google.com>
To: Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: Re: [PATCH] arm64: mm: enable per pmd page table lock
Message-ID: <20190218204842.GA203083@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218151223.GB16091@fuggles.cambridge.arm.com>
 <20190218194938.GA184109@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218194938.GA184109@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 12:49:38PM -0700, Yu Zhao wrote:
> On Mon, Feb 18, 2019 at 03:12:23PM +0000, Will Deacon wrote:
> > [+Mark]
> > 
> > On Thu, Feb 14, 2019 at 02:16:42PM -0700, Yu Zhao wrote:
> > > Switch from per mm_struct to per pmd page table lock by enabling
> > > ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> > > large system.
> > > 
> > > I'm not sure if there is contention on mm->page_table_lock. Given
> > > the option comes at no cost (apart from initializing more spin
> > > locks), why not enable it now.
> > > 
> > > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > > ---
> > >  arch/arm64/Kconfig               |  3 +++
> > >  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
> > >  arch/arm64/include/asm/tlb.h     |  5 ++++-
> > >  3 files changed, 18 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > > index a4168d366127..104325a1ffc3 100644
> > > --- a/arch/arm64/Kconfig
> > > +++ b/arch/arm64/Kconfig
> > > @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
> > >  config ARCH_HAS_CACHE_LINE_SIZE
> > >  	def_bool y
> > >  
> > > +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> > > +	def_bool y
> > > +
> > >  config SECCOMP
> > >  	bool "Enable seccomp to safely compute untrusted bytecode"
> > >  	---help---
> > > diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> > > index 52fa47c73bf0..dabba4b2c61f 100644
> > > --- a/arch/arm64/include/asm/pgalloc.h
> > > +++ b/arch/arm64/include/asm/pgalloc.h
> > > @@ -33,12 +33,22 @@
> > >  
> > >  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
> > >  {
> > > -	return (pmd_t *)__get_free_page(PGALLOC_GFP);
> > > +	struct page *page;
> > > +
> > > +	page = alloc_page(PGALLOC_GFP);
> > > +	if (!page)
> > > +		return NULL;
> > > +	if (!pgtable_pmd_page_ctor(page)) {
> > > +		__free_page(page);
> > > +		return NULL;
> > > +	}
> > > +	return page_address(page);
> > 
> > I'm a bit worried as to how this interacts with the page-table code in
> > arch/arm64/mm/mmu.c when pgd_pgtable_alloc is used as the allocator. It
> > looks like that currently always calls pgtable_page_ctor(), regardless of
> > level. Do we now need a separate allocator function for the PMD level?
> 
> Thanks for reminding me, I never noticed this. The short answer is
> no.
> 
> I guess pgtable_page_ctor() is used on all pud/pmd/pte entries
> there because it's also compatible with pud, and pmd too without
> this patch. So your concern is valid. Thanks again.
> 
> Why my answer is no? Because I don't think the ctor matters for
> pgd_pgtable_alloc(). The ctor is only required for userspace page
> tables, and that's why we don't have it in pte_alloc_one_kernel().
> AFAICT, none of the pgds (efi_mm.pgd, tramp_pg_dir and init_mm.pgd)
> pre-populated by pgd_pgtable_alloc() is. (I doubt we pre-populate
> userspace page tables in any other arch).
> 
> So to avoid future confusion, we might just remove the ctor from
> pgd_pgtable_alloc().

I'm sorry. I've missed that we call apply_to_page_range() on efi_mm.
The function does require the ctor. So we actually can't remove it.
Though pgtable_page_ctor() also does the work adequately for pmd in
terms of giving apply_to_page_range() what it requires, it would be
more appropriate to use pgtable_pmd_page_ctor() instead (and not
calling the ctor at all on pud).

I could add this change prior to this patch, if it makes sense to
you. Thanks.


Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D108C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 19:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18102217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 19:49:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lnCZINN7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18102217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 813FF8E0003; Mon, 18 Feb 2019 14:49:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C4368E0002; Mon, 18 Feb 2019 14:49:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D90E8E0003; Mon, 18 Feb 2019 14:49:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48AFD8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 14:49:43 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i4so505666itb.1
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 11:49:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0wtsBdExeMA1wwCJ28I4aSi9QBIDjm+ySXCh9WlH+r8=;
        b=O8Fh4yhQW6c7bPY16NFpkhtMTeHf0Ol0UFCAlX9UnQG9ANbsOmyD/FzsAHWZdzkaRK
         NF0KL5Eeko0jRGA5PqeeQE27XtZEQsMbz7OcGL8gkaKNAx1HjA1LOrh9nDgZKp05EWGo
         nECekFMAEmzUg0I9Edd4pbg7QjA3gawsyoRoiSEPrevUMx1ant4cSycKXjAHgVNg7SJp
         WKUsc0sdXkdcOCqv2k1MIumiMeF8QbC+bkLmys4OVOB4BrjvcXylU56wokDcwKoWzVeA
         QCviSH96WoojA0RSs3ESaWZXdLVLZkqo2k58YO/Av3tyDkU26SlHEA0b2syeQ57s/RWG
         XjWw==
X-Gm-Message-State: AHQUAubUWW/NXjVap0ePedlpAXG/2g9oSfC/A9B1Rflt2mmg5ZU5gRLa
	gMdIT0CWJk8uk/mLquSZiqHlFKd7MZZTS+9rCBc4rM0O/1WfMciLSChk5m1KMPydfSyM+dL0iPP
	58YnjjtBtDpjLJ93jO5uKdNC/6rbZt3y3qZtqQhD9TtJF3F+DUfJcJZlsAnkZPVhKqFsxBoUQty
	aizjBijba/LgFljSluXKrVz3bbXFRli0hwM2VvSPBOPm3gEwcFSLmvROl455O4o4KFh0blwFEGH
	jvbV5qtrrT0L8SPUyo1ipM+mRTZ4JcYqZ4d/CpLsKsF6X6yd92Dd1cCwe8PmiFV0MJa/2N1EbeI
	13YS+LWK6556c7ZURGvppH1V+juMW+8xa5jmooVlnithnBhP6EvylWdu1uYxhMg6ehnSMausaY/
	v
X-Received: by 2002:a6b:6507:: with SMTP id z7mr7917914iob.275.1550519383070;
        Mon, 18 Feb 2019 11:49:43 -0800 (PST)
X-Received: by 2002:a6b:6507:: with SMTP id z7mr7917892iob.275.1550519382273;
        Mon, 18 Feb 2019 11:49:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550519382; cv=none;
        d=google.com; s=arc-20160816;
        b=B9wy7usPyWk73u9taQbY5l9tSjd9iBBGeUV+lckUimQwlr453s4X5UOgX/NcQPI0No
         yodcIKqVQMd0SN4zmsM0cDcHxbKyC5fGSgJviSmDmsao7tFYyAIs8N27L4pKdZhdwEiB
         FKfBLth+GsbG/cvLF3LcdHi+ZAx5MlpD5a1ydol6McsiYwB3ySGX/6+C9M0ZK7luF23E
         arA5BkrzHzmjHn5m07rTJLwB2pDj2toh0P9GPu+k85v9Wvq6v8hszBeB43KlJq3il7Nq
         jOqCNjncTOTMvoj8eY02hhYAybcglDTEFaAwxfMt3geQfTmnSmha3G94YT2o8ZQE5BFv
         p8SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0wtsBdExeMA1wwCJ28I4aSi9QBIDjm+ySXCh9WlH+r8=;
        b=ee+TzuG4zR8btDvv1LZ9EUBjHssOOoGS7Ndbb1PQA7aV3h9vKngnMj68wPFiZ3Pk2h
         QG8v82XMmWS0JWh7iER6/YzLsECT/eRZFZQfgaKDccwiHpgCtOE017yPgQef+jpf9nsP
         Aoe0yQpfIPO5C9yNVTwExPQWzb2FzPjuhkmAzOWjyqmliN9/ZcMOSUzy6trIFRSZJfeS
         BALdSNKAH8xD9IGLNruHC4auZ/ALOL8NklE2uI8TJRSo6frRpoQO6M7+rmi+hA6BldPF
         KEQgmS27Q1TQKHy1LE33de5Wpue1gXiKhPU4azqgIgMeJyf/FBV9vpXB1zB008RngEcX
         Bsiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lnCZINN7;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14sor34141746jac.7.2019.02.18.11.49.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 11:49:42 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lnCZINN7;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0wtsBdExeMA1wwCJ28I4aSi9QBIDjm+ySXCh9WlH+r8=;
        b=lnCZINN7IoVMhyN6Ibb/qlSwbfdgcKLoKqRCpyFvlLWtuAoP/FCJcQKLFGQi09gDVr
         5DiPNsJ3wLufD+iHIhNZDCwwyRCLWiwKRGn/GJIg8q191GC4x6c+6wVVnjJ1WaSYzq9O
         3x4YrPPt0p1oh4zkAc1KgwK83gxLOg25m+qlcqCvbwwptQv/6HSlZVPVC36c+OTBDIBy
         APQe2ue7roT6A2u6aQFmTgeF65aUI+pCdpn/VkyjDeN3Lu2FSg8S8Dqg0Li9uFHFoFEt
         Kjpz3ydKeddO0GqHPTLYFF+2YmEsV0f+vPa64ELLx8sRS1MhTdY5T/XF3M1qgBM3LpeO
         eB8A==
X-Google-Smtp-Source: AHgI3IYgK3DVojWmklhiIeoLq404ESnMMVIaR2vGDGMXORI8El0uFkQrhGihzkrV0E3C0Mg6kZr77A==
X-Received: by 2002:a02:c943:: with SMTP id u3mr13451152jao.96.1550519381443;
        Mon, 18 Feb 2019 11:49:41 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id x17sm5606036ioa.6.2019.02.18.11.49.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 11:49:40 -0800 (PST)
Date: Mon, 18 Feb 2019 12:49:38 -0700
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
Message-ID: <20190218194938.GA184109@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218151223.GB16091@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218151223.GB16091@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 03:12:23PM +0000, Will Deacon wrote:
> [+Mark]
> 
> On Thu, Feb 14, 2019 at 02:16:42PM -0700, Yu Zhao wrote:
> > Switch from per mm_struct to per pmd page table lock by enabling
> > ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> > large system.
> > 
> > I'm not sure if there is contention on mm->page_table_lock. Given
> > the option comes at no cost (apart from initializing more spin
> > locks), why not enable it now.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  arch/arm64/Kconfig               |  3 +++
> >  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
> >  arch/arm64/include/asm/tlb.h     |  5 ++++-
> >  3 files changed, 18 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index a4168d366127..104325a1ffc3 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
> >  config ARCH_HAS_CACHE_LINE_SIZE
> >  	def_bool y
> >  
> > +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> > +	def_bool y
> > +
> >  config SECCOMP
> >  	bool "Enable seccomp to safely compute untrusted bytecode"
> >  	---help---
> > diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> > index 52fa47c73bf0..dabba4b2c61f 100644
> > --- a/arch/arm64/include/asm/pgalloc.h
> > +++ b/arch/arm64/include/asm/pgalloc.h
> > @@ -33,12 +33,22 @@
> >  
> >  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
> >  {
> > -	return (pmd_t *)__get_free_page(PGALLOC_GFP);
> > +	struct page *page;
> > +
> > +	page = alloc_page(PGALLOC_GFP);
> > +	if (!page)
> > +		return NULL;
> > +	if (!pgtable_pmd_page_ctor(page)) {
> > +		__free_page(page);
> > +		return NULL;
> > +	}
> > +	return page_address(page);
> 
> I'm a bit worried as to how this interacts with the page-table code in
> arch/arm64/mm/mmu.c when pgd_pgtable_alloc is used as the allocator. It
> looks like that currently always calls pgtable_page_ctor(), regardless of
> level. Do we now need a separate allocator function for the PMD level?

Thanks for reminding me, I never noticed this. The short answer is
no.

I guess pgtable_page_ctor() is used on all pud/pmd/pte entries
there because it's also compatible with pud, and pmd too without
this patch. So your concern is valid. Thanks again.

Why my answer is no? Because I don't think the ctor matters for
pgd_pgtable_alloc(). The ctor is only required for userspace page
tables, and that's why we don't have it in pte_alloc_one_kernel().
AFAICT, none of the pgds (efi_mm.pgd, tramp_pg_dir and init_mm.pgd)
pre-populated by pgd_pgtable_alloc() is. (I doubt we pre-populate
userspace page tables in any other arch).

So to avoid future confusion, we might just remove the ctor from
pgd_pgtable_alloc().


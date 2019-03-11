Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE9DCC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:11:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89A932087F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:11:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="akr6VVQL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89A932087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4FA8E0003; Mon, 11 Mar 2019 19:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A4148E0002; Mon, 11 Mar 2019 19:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16D338E0003; Mon, 11 Mar 2019 19:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id E316E8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:11:39 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id q192so559306itb.9
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:11:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xQ8xaS8h2fYbojq0arP/xyISP9DGV1Q5pEy67dnoLHk=;
        b=IaSnoVmiKIdOr9XWUPd0ZWBerexTW2zppAt5OekHytJOQ3vUtJqo1fWR4ODRo3foSn
         Scl7H73iHyKuus5Pjx8HV63zhx4eMaAEaG0IOywc8CFmdTYt2mALcoDKJz26RXsbFivu
         Uk3fHnkmmc86K1+iKxjGm4J/+5Y32CVW/A2V0QOzmZA3Ja55sHBtii37jloARYfJ38Rl
         62CiArrjkphbtZpvdyovsr3Nke70wDhS6tvXj3yr2pq2sN5Cco2jY5UU5J7IZjeOy1bk
         HkhKQQhuCccYk43SrnX78cEkSt2GskoUTYA3TvoskPUIWR9/cUsIgX7+NPu0BCmuBsmM
         Acbw==
X-Gm-Message-State: APjAAAXhKhcNpkE5g05mdToCNMs7xG3/4osYJlS9g3i/cfZ23VB3C2NM
	rSFowRN1WD6898j2OyAVyUukd9P0QVUg2CRvbLTD9PrCpzgzayiIGPWlOwSpnYMotqbSsa9Dsxm
	St2RRQiOAHfSjkkQrNuxpDPckGJnTa3gBJdrrMI/votM32guJ+sYQm+xkiUNZTDPw2dt+Hae5/a
	Ng9ZvkGpye891Kw8Rj/aH0RAyj7tXecZpx8xvkxkzhYCSlveGBLDsHXvWhEsWpfA3pcdzgj4XpN
	YIiboVHjgZglCuuJOlx5xBVuxxTgLrElHn+x1WEBhVnlBbeQ4LCay+Qnc1Z9Qysf+9tKsNx5vgC
	NVg4P3o0fFMh3Agc7gVxA7jM1G3BT1y1n5PonvXsng6FMXkfI2metf0yBUTlDMEVRpBwDPoWboW
	z
X-Received: by 2002:a6b:e50a:: with SMTP id y10mr4884942ioc.91.1552345899672;
        Mon, 11 Mar 2019 16:11:39 -0700 (PDT)
X-Received: by 2002:a6b:e50a:: with SMTP id y10mr4884906ioc.91.1552345898901;
        Mon, 11 Mar 2019 16:11:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552345898; cv=none;
        d=google.com; s=arc-20160816;
        b=cYFCIf7Flg0VC4Pv5PJdB/hw5S31eKaXw8BpYWVaQJRI6XGOBfPjXRdx1WhywsDRpK
         akxkqfF5MWG4cYKA8C8K3Uj1UILpqD9hGhai/apa5WeEEvp/e5KG6DVI5/2m2Xfup+vc
         J02WfooLVsNVdMc8rYSSqdqlFevwU0uw8D86nhhRb7SPvFpOv/Q7BicswopHqX09VTU8
         qzPSClBgEx3AraRh0FdIEcHIpTnSsN9H3qHe3LrsGASFsj8OLScvt93Q4TU7cQr8nMnA
         AQd/Coir0/d/8Fw/lshyC/Pa8l493VSVPASixwQfC3w4bSKQ1+FPua4oRD90wq56N+Y0
         J0WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xQ8xaS8h2fYbojq0arP/xyISP9DGV1Q5pEy67dnoLHk=;
        b=g4ro7ngHGBCOBAjWq6T8bb9jKNMlYXBMt2b9pCJMNOagxKz90jcYXIiPBGWhJHDaeL
         Bp8bi6Q2mUqD/q8wTFQg0P02zYmHmIWUXaFh6cm9joDXd/VlrvgqwqbogfdyuMPbCCvM
         NWNm7bure4qOtSS5CRc2uMzIPfiFePDRkZyY+A7f2c5uQm1sWCgmLW3X+5EHqbUe8vb2
         0k3an8MA6Gx0oCgS21mX6fnHAPJuqXD8pjys78USvLRuAlwXwilEDC1ejHQz2eHjvKtc
         BWyHo2Vm0l/fvyg8DI4FaxYVqnMJk0FgIexbzbAgRwcNgpFEP/fYoNEUwJbxOmQlnGkw
         pYzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=akr6VVQL;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69sor16614172jaa.0.2019.03.11.16.11.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 16:11:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=akr6VVQL;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xQ8xaS8h2fYbojq0arP/xyISP9DGV1Q5pEy67dnoLHk=;
        b=akr6VVQLAUmwWPCDyPKBcWtRHQZIYV9WsoybdAYHJbH+NDwLbiNiQo4XHeGBqkvmBJ
         jNk1sT0vRKf8UK6PB365SQdyjbNTP3GRUuj/ibF5+vhPJs8spEhOzRmkRM4FglLSPMCD
         1Ybm3rnhODYuK8hvtBH5dG/3DsfNx3MVPYtj0pHUnHWEYu67WJ5XgqbZfSu9ebme/TFN
         m7FoObLXHxl04LLHwFiL6oa1FdnTNOSFBtVLDeLNZnIx1Jf+N4uRAaEVSYUNX0jy9N/V
         UObR67/jDPGJ7SJwbu7/GRGt3nhgo8wN5Iqdojo/6GMqksr4Jzfl7N7ZAnBsSifN5+qw
         G7zg==
X-Google-Smtp-Source: APXvYqwMcdqDIsHo+RT4qrhdUL6SBTvYE1XQYfNVhTWFiImkU6gfS1pNx9Cq0PRDj3KY9Jsf6Js3eQ==
X-Received: by 2002:a05:6638:398:: with SMTP id y24mr19937029jap.33.1552345898513;
        Mon, 11 Mar 2019 16:11:38 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id x24sm2849861ioa.50.2019.03.11.16.11.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 11 Mar 2019 16:11:37 -0700 (PDT)
Date: Mon, 11 Mar 2019 17:11:33 -0600
From: Yu Zhao <yuzhao@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 3/3] arm64: mm: enable per pmd page table lock
Message-ID: <20190311231133.GB207964@google.com>
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
 <20190310011906.254635-3-yuzhao@google.com>
 <20190311121147.GA23361@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311121147.GA23361@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 12:12:28PM +0000, Mark Rutland wrote:
> Hi,
> 
> On Sat, Mar 09, 2019 at 06:19:06PM -0700, Yu Zhao wrote:
> > Switch from per mm_struct to per pmd page table lock by enabling
> > ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> > large system.
> > 
> > I'm not sure if there is contention on mm->page_table_lock. Given
> > the option comes at no cost (apart from initializing more spin
> > locks), why not enable it now.
> > 
> > We only do so when pmd is not folded, so we don't mistakenly call
> > pgtable_pmd_page_ctor() on pud or p4d in pgd_pgtable_alloc(). (We
> > check shift against PMD_SHIFT, which is same as PUD_SHIFT when pmd
> > is folded).
> 
> Just to check, I take it pgtable_pmd_page_ctor() is now a NOP when the
> PMD is folded, and this last paragraph is stale?

Yes, and will remove it.

> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  arch/arm64/Kconfig               |  3 +++
> >  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
> >  arch/arm64/include/asm/tlb.h     |  5 ++++-
> >  3 files changed, 18 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index cfbf307d6dc4..a3b1b789f766 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
> >  config ARCH_HAS_CACHE_LINE_SIZE
> >  	def_bool y
> >  
> > +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> > +	def_bool y if PGTABLE_LEVELS > 2
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
> >  }
> >  
> >  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
> >  {
> >  	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
> > +	pgtable_pmd_page_dtor(virt_to_page(pmdp));
> >  	free_page((unsigned long)pmdp);
> >  }
> 
> It looks like arm64's existing stage-2 code is inconsistent across
> alloc/free, and IIUC this change might turn that into a real problem.
> Currently we allocate all levels of stage-2 table with
> __get_free_page(), but free them with p?d_free(). We always miss the
> ctor and always use the dtor.
> 
> Other than that, this patch looks fine to me, but I'd feel more
> comfortable if we could first fix the stage-2 code to free those stage-2
> tables without invoking the dtor.
> 
> Anshuman, IIRC you had a patch to fix the stage-2 code to not invoke the
> dtors. If so, could you please post that so that we could take it as a
> preparatory patch for this series?

Will do.

> Thanks,
> Mark.
> 
> > diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> > index 106fdc951b6e..4e3becfed387 100644
> > --- a/arch/arm64/include/asm/tlb.h
> > +++ b/arch/arm64/include/asm/tlb.h
> > @@ -62,7 +62,10 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
> >  static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
> >  				  unsigned long addr)
> >  {
> > -	tlb_remove_table(tlb, virt_to_page(pmdp));
> > +	struct page *page = virt_to_page(pmdp);
> > +
> > +	pgtable_pmd_page_dtor(page);
> > +	tlb_remove_table(tlb, page);
> >  }
> >  #endif
> >  
> > -- 
> > 2.21.0.360.g471c308f928-goog
> > 


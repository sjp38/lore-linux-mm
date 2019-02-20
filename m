Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFFF5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:22:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 914A22146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 20:22:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="geWMICWp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 914A22146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35BD48E002F; Wed, 20 Feb 2019 15:22:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30BEA8E0002; Wed, 20 Feb 2019 15:22:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 223508E002F; Wed, 20 Feb 2019 15:22:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED9D18E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:22:48 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id j3so12839060itf.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 12:22:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=66Ke7E27wbc1VrqcktMRXfyv/CVpPFUGEc9h69ihMvs=;
        b=n9vqLFbw7xhy+AAEg0oFfipYjTV+a7/szzrPkPAEIQxIoK8oK3DRQb52/TDj2vvW2F
         +8eKOl07B6hIpirMY7ccrf+ygKgKgt9HjNpfIjC0tg2v0FmEPsvw5/aAmN1Uoyjx8jVj
         6hShsKgyyGIlf6zdj+Z5k947zRU2jRKJwmH1PrqF5c6KFMj9AcV6mGq0OHQ0VjmTxkw3
         faNxfUu4+ycBNacVAhEfi8FVNIXtc/Y08NmPAzBV+pmhmZYHJTuuJ0UFbJ71s7tJsJBe
         LXekLeE4SCNfvdE2nqDi5gkYtrjbZG92bDPhONMt1tGJ/9m2ahNk3Ty7Biv8mheKjXlA
         RY6g==
X-Gm-Message-State: AHQUAuZ0NFbswI/PmgB8uqlv+rwKtyiMiujdkQDrJLIR/PMC3D7g8P/f
	2NoJLGse2aC1vLURNspA688o6FnxHvvGrx9jODyV4L86NmYNSxuxOyS3UmC5a/jR7mypJt960AT
	1LFr3EX1SPq3fx2t63WA/JVV9co65mKqkQR+MBzMUoIvbe6eAiGdXKZEhDEf124hMl5f9xuVZKA
	R3YR483Fc7g3gEtNaYZz52ZxVWLvpt09UbTFxwjdOQp2XFrvQN0J0a0zwbV4YQYph/28oVriRXC
	0cVbzdIahYGMuaEAgAGYOf1Et8K9B/XyEwQYGGnh961mjYf0Ytzxlpe5Cte9tWVo4/bj/72QgcX
	CkTftHD0Wy/MXCx5Em5XUoNBMGtxp+7F5aRprDsHoMghDqT1UdHMyLBZAz5sGI+/ilwMlO5NFWU
	U
X-Received: by 2002:a02:8c3c:: with SMTP id l57mr20896517jak.73.1550694168739;
        Wed, 20 Feb 2019 12:22:48 -0800 (PST)
X-Received: by 2002:a02:8c3c:: with SMTP id l57mr20896492jak.73.1550694167968;
        Wed, 20 Feb 2019 12:22:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550694167; cv=none;
        d=google.com; s=arc-20160816;
        b=ZBKBpxbmpxS/sHIyDjATULV7OYY/XErFzgeLr0isEH3DLEo8jBQkHPrBKqbc+5cpau
         I2buR2sU23p3O7/4srIqJiigbMGJlWE0nuObYnC5Nvg1EsD7jrl0/NCAPDHKZxHCsMh3
         ckxIhcv26QK8Yy14NaP0fMLOcI90oOkvzjTsq7qxu8lgnvNhzeX0QCn9EtiZ1aRVr8Lf
         TrrTesTphl4fBwe5ojD8fWG/EOLGnI8QkX8Rdt8Hl1Ibn9QY+GuDTYUKuvVoNvNySkyw
         8DdP8UJv1ahbH6Tv41xjFlDHnzqWWd+6GPGujCBjm4bbbXfxA/EWSR+SuThiBt0EJUi5
         Gs9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=66Ke7E27wbc1VrqcktMRXfyv/CVpPFUGEc9h69ihMvs=;
        b=MWUBU027hzvXZKy0ErmGCQsLx1ZBtIhhzUmy2r4cR0+qhYl5bBD5hhQTr4P0Ng0WjQ
         xTb7gyK5FPAurqF9SS7qKUcDlCfpo4HX33P4fLWSBcQPV0ycwCpsI/TxRM9XVVNZN1mB
         8Xu+U5aZ83te8VYGokrn8lTYeGUS9Qlba5Jnx/eyKeDztc5n2p89Q1n0hSZWHuBCfJhG
         eFChx1RSZlPkgEhaqPs+Jd/rocY/BeQg5KHNS0PPXCWvSKEq934JnbV2IMNDxVtfCsAC
         RLmZHZhwpPrW6fsygk2ZgW2k6CQ2WMXsq4M3TKYqxFl22sTg8T06i50KGv/pftm7T4Rs
         DzhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=geWMICWp;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d188sor10187096ite.10.2019.02.20.12.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 12:22:47 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=geWMICWp;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=66Ke7E27wbc1VrqcktMRXfyv/CVpPFUGEc9h69ihMvs=;
        b=geWMICWpgJnSV1zU7/uendmGRR3pkA3XSbiRWKoXJuUhyXv6fDtHlyiAf5B44CLFx5
         uuYcXoSzsvduXFHSao3q7nW8inTPczfYFYQh8iA24WQIQY249DIuhKL97ofFtuFetJS+
         ZH3AV30s4r1lJqByQ/WeFTukPYA1WxG4wTh2tMFIdkIXEzokrHxnEIy78m1JzY835rL9
         ECntYu5aIJ/Z3YRyjbyV2/Wmy657P6dFY+kNlz9cDkBuFoR1ocK3DGBhlWRPN8CAjh7j
         +JSqntkxRJktrMOX+u1jrXUTVMh1ANrkh3QZDnjNhSDQSTVL4Utbua8WAfoFlEHUk2yr
         2FJg==
X-Google-Smtp-Source: AHgI3IaCh6zrF4Pd5EWFap5bohM+OrY6h+PowTxsOX6YudliX0BShK+1A0JUsxRz5WDNcbH2i0v/ig==
X-Received: by 2002:a05:660c:54d:: with SMTP id w13mr6181600itk.50.1550694167405;
        Wed, 20 Feb 2019 12:22:47 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id c19sm8331863ioh.4.2019.02.20.12.22.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 12:22:46 -0800 (PST)
Date: Wed, 20 Feb 2019 13:22:44 -0700
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
Message-ID: <20190220202244.GA80497@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <863acc9a-53fb-86ad-4521-828ee8d9c222@arm.com>
 <20190219053205.GA124985@google.com>
 <8f9b0bfb-b787-fa3e-7322-73a56a618aa8@arm.com>
 <20190219222828.GA68281@google.com>
 <f7e4db43-b836-4ac2-1aea-922be585d8b1@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f7e4db43-b836-4ac2-1aea-922be585d8b1@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 03:57:59PM +0530, Anshuman Khandual wrote:
> 
> 
> On 02/20/2019 03:58 AM, Yu Zhao wrote:
> > On Tue, Feb 19, 2019 at 11:47:12AM +0530, Anshuman Khandual wrote:
> >> + Matthew Wilcox
> >>
> >> On 02/19/2019 11:02 AM, Yu Zhao wrote:
> >>> On Tue, Feb 19, 2019 at 09:51:01AM +0530, Anshuman Khandual wrote:
> >>>>
> >>>>
> >>>> On 02/19/2019 04:43 AM, Yu Zhao wrote:
> >>>>> For pte page, use pgtable_page_ctor(); for pmd page, use
> >>>>> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> >>>>> p4d and pgd), don't use any.
> >>>> pgtable_page_ctor()/dtor() is not optional for any level page table page
> >>>> as it determines the struct page state and zone statistics.
> >>>
> >>> This is not true. pgtable_page_ctor() is only meant for user pte
> >>> page. The name isn't perfect (we named it this way before we had
> >>> split pmd page table lock, and never bothered to change it).
> >>>
> >>> The commit cccd843f54be ("mm: mark pages in use for page tables")
> >>> clearly states so:
> >>>   Note that only pages currently accounted as NR_PAGETABLES are
> >>>   tracked as PageTable; this does not include pgd/p4d/pud/pmd pages.
> >>
> >> I think the commit is the following one and it does say so. But what is
> >> the rationale of tagging only PTE page as PageTable and updating the zone
> >> stat but not doing so for higher level page table pages ? Are not they
> >> used as page table pages ? Should not they count towards NR_PAGETABLE ?
> >>
> >> 1d40a5ea01d53251c ("mm: mark pages in use for page tables")
> > 
> > Well, I was just trying to clarify how the ctor is meant to be used.
> > The rational behind it is probably another topic.
> > 
> > For starters, the number of pmd/pud/p4d/pgd is at least two orders
> > of magnitude less than the number of pte, which makes them almost
> > negligible. And some archs use kmem for them, so it's infeasible to
> > SetPageTable on or account them in the way the ctor does on those
> > archs.
> > 
> 
> I understand the kmem cases which are definitely problematic and should
> be fixed. IIRC there is a mechanism to custom init pages allocated for
> slab cache with a ctor function which in turn can call pgtable_page_ctor().
> But destructor helper support for slab has been dropped I guess.
> 
> 
> > But, as I said, it's not something can't be changed. It's just not
> > the concern of this patch.
> 
> Using pgtable_pmd_page_ctor() during PMD level pgtable page allocation
> as suggested in the patch breaks pmd_alloc_one() changes as per the
> previous proposal. Hence we all would need some agreement here.
> 
> https://www.spinics.net/lists/arm-kernel/msg701960.html

A proposal that requires all page tables to go through a same set of
ctors on all archs is not only inefficient (for kernel page tables)
but also infeasible (for arches use kmem for page tables). I've
explained this clearly.

The generalized page table functions must recognize the differences
on different levels and between user and kernel page tables, and
provide unified api that is capable of handling the differences.

The change below is not helping at all.

> 
> We can still accommodate the split PMD ptlock feature in pmd_alloc_one().
> A possible solution can be like this above and over the previous series.
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a4168d366127..c02abb2a69f7 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -9,6 +9,7 @@ config ARM64
>         select ACPI_SPCR_TABLE if ACPI
>         select ACPI_PPTT if ACPI
>         select ARCH_CLOCKSOURCE_DATA
> +       select ARCH_ENABLE_SPLIT_PMD_PTLOCK if HAVE_ARCH_TRANSPARENT_HUGEPAGE
>         select ARCH_HAS_DEBUG_VIRTUAL
>         select ARCH_HAS_DEVMEM_IS_ALLOWED
>         select ARCH_HAS_DMA_COHERENT_TO_PFN
> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> index a02a4d1d967d..258e09fb3ce2 100644
> --- a/arch/arm64/include/asm/pgalloc.h
> +++ b/arch/arm64/include/asm/pgalloc.h
> @@ -37,13 +37,29 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t pte);
>  
>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>  {
> -       return (pmd_t *)pte_alloc_one_virt(mm);
> +       pgtable_t ptr;
> +
> +       ptr = pte_alloc_one(mm);
> +       if (!ptr)
> +               return 0;
> +
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> +       ptr->pmd_huge_pte = NULL;
> +#endif
> +       return (pmd_t *)page_to_virt(ptr);
>  }
>  
>  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
>  {
> +       struct page *page;
> +
>         BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
> -       pte_free(mm, virt_to_page(pmdp));
> +       page = virt_to_page(pmdp);
> +
> +#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
> +       VM_BUG_ON_PAGE(page->pmd_huge_pte, page);
> +#endif
> +       pte_free(mm, page);
>  }
> 
> 
> > 
> >>>
> >>> I'm sure if we go back further, we can find similar stories: we
> >>> don't set PageTable on page tables other than pte; and we don't
> >>> account page tables other than pte. I don't have any objection if
> >>> you want change these two. But please make sure they are consistent
> >>> across all archs.
> >>
> >> pgtable_page_ctor/dtor() use across arch is not consistent and there is a need
> >> for generalization which has been already acknowledged earlier. But for now we
> >> can atleast fix this on arm64.
> >>
> >> https://lore.kernel.org/lkml/1547619692-7946-1-git-send-email-anshuman.khandual@arm.com/
> > 
> > This is again not true. Please stop making claims not backed up by
> > facts. And the link is completely irrelevant to the ctor.
> > 
> > I just checked *all* arches. Only four arches call the ctor outside
> > pte_alloc_one(). They are arm, arm64, ppc and s390. The last two do
> > so not because they want to SetPageTable on or account pmd/pud/p4d/
> > pgd, but because they have to work around something, as arm/arm64
> > do.
> 
> That reaffirms the fact that pgtable_page_ctor()/dtor() are getting used
> not in a consistent manner.

Now it's getting absurd. I'll just stop before this turns into
complete nonsense.


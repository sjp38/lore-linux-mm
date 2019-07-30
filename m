Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1900EC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6573206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:03:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="tynKo5h1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6573206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 619F08E0007; Tue, 30 Jul 2019 13:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CB288E0001; Tue, 30 Jul 2019 13:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 492A48E0007; Tue, 30 Jul 2019 13:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 133188E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:03:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n3so31123078pgh.12
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sjiuOj4pMy3XulfjH+DlQM2jh5+llnycx9G2HKmD8Vc=;
        b=bu3UdoTkolF+OPh620RMNSBcT5dC+YG5a/Ay2eQ8Eoyw7iJKOfpGw+cY01T5WUZPO0
         sw5D0lFy7QhKJdelPXnkBU4JnTz199cjrClyGMccnS+q9GEqNfhakBjyworT4bJMsoqv
         09sIaCnjzZ01on//Ty55oacY+S0UZQ4zddt1YRLbNY9WhE1YtOfijbSxQPFmdIml75fW
         rBV1yigrggW47v7NEPCOWd0GB9V5ih+wVFVIwOrZQXDLTtsLO3bGb8KwYj6ahorPTkKE
         SlNXEiWHUgy1pX0YAOmhZ6H5RaXDmwMKFwksbLT9b3jzBrrZTFyIxF1c/9VKjMZDEeiK
         NaHw==
X-Gm-Message-State: APjAAAX746dSDiVorx3mwrXsTENWCGpcr9hSozGo4hvlmS7JEzHvmcMw
	wj1TpfUIlPV5ShL1mFjKLMwaI6vkWICTBdDITY3P0uvnx9TrE/ErZpJs0NnsbQ2eV/7xgvvTZO3
	3bnEdDZoHwY1R0ROMiEvIej62Bf3jQvhGCOQ07T3E9ELCT8Aml6r+277Ae+XFGmBX2g==
X-Received: by 2002:a63:608c:: with SMTP id u134mr111137157pgb.274.1564506206418;
        Tue, 30 Jul 2019 10:03:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi1qRYAyO/YmAbXkyN8xCYN38GjZQ1iXVwApOYpK6dpGaAKMHmH6+2OhhEmXhW0cOOB6zu
X-Received: by 2002:a63:608c:: with SMTP id u134mr111137048pgb.274.1564506205112;
        Tue, 30 Jul 2019 10:03:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564506205; cv=none;
        d=google.com; s=arc-20160816;
        b=VBSEUwrH8hjKwPvuFKPuwqEb/p4CwQftL0OQl9HGybmixi2IPiqeN1iqYdsjfhaCTp
         hnNLH/9XMzu7K7ZDCjoTDq6YnxRnMivCofMIdxL7dIzhowOj3b1vXjxPk8WS42rJHo2K
         qKxqTMwPpcmoJ7f66lmbBPejZwLPjDq4gXou8xASZAgxq8TzmbkumJT8KjAfWZLZ5u9v
         5jSORAbNm05DAw2ITcD/8dyKCYDVl2H4wuaAdL6VI6fiodLcgUt2vgmRNMPZjnptv9Ee
         lyXx5j0J9oxVeoQoNWJxqWSnPEFhATwMNSZRYf1HBGb8x0zeg4O1BuYzkHr9rC3atMg+
         CYWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sjiuOj4pMy3XulfjH+DlQM2jh5+llnycx9G2HKmD8Vc=;
        b=tFq58JWpG7ZwMKi8IQMCOv2liFXOlH1wcdw9oVrQ2QopDSZj2/XpuS+ycMvpYtilo/
         zzymPFHsWNvheudYRFs3xl+VTmnbZACMd4+oemDow0aGkwlvtHSug/pcCmFXtEJdF06J
         LVn4UJCsk0uQUbdtW8uhpFB/ysURiz/PGGUjadVAUlqQARsFeh+CkA2WWLBVGlE3SDHI
         nmcoKmB8fOjokGaV3Cqh1EhKcV+pl3X+2hdSBVpaPML2XbxbZoArTfIQO67BjupWxTxx
         IvqbMDLGHPAGThBjp32Rv6HaOPTkdf2IR4u9Uzq5j3Cq64KesBRPEMt1CXEkFc2lGNUG
         lU3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tynKo5h1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 78si29135374pfz.268.2019.07.30.10.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 10:03:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=tynKo5h1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sjiuOj4pMy3XulfjH+DlQM2jh5+llnycx9G2HKmD8Vc=; b=tynKo5h1HQy7lnlRTfMfJI0pk
	7ax4izVZLE13fK7Cnt+YJSjkC5S9KF2xgwaJexGTyyumMr0wljno8OXBZ9dFLeaEl/Qz3rmVPNRoW
	g7B8mddz/HHVNh4rJzkAfwNzwxZ/hOWEqoD+MX2L5jW7MVuNp+H5Y2L+e2RmPd1mwKAoQ2MEPPj6J
	eYhy22Kd64NFLgHXi/mfKsOOcSQBC2LuBDXYS3LG0ePdhgsD/Tple33zqS2yLdqY8XkmblbgsSd9z
	rzb83uC2QeEG1fK6eSlKeg4bne9CZYu0mshYUz07DDDpYDRj4eejwt92HEifZNS9M8C/NW7YbHMFB
	hyUrU+BXQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsVX1-0006YE-Pq; Tue, 30 Jul 2019 17:03:23 +0000
Date: Tue, 30 Jul 2019 10:03:23 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-arm-kernel@lists.infradead.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190730170323.GA4700@bombadil.infradead.org>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
 <20190725143920.GW363@bombadil.infradead.org>
 <c3bb0420-584c-de3b-2439-8702bc09595e@arm.com>
 <20190726195457.GI30641@bombadil.infradead.org>
 <10ed1022-a5c0-c80c-c0c9-025bb2307666@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <10ed1022-a5c0-c80c-c0c9-025bb2307666@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 02:02:52PM +0530, Anshuman Khandual wrote:
> On 07/27/2019 01:24 AM, Matthew Wilcox wrote:
> > On Fri, Jul 26, 2019 at 10:17:11AM +0530, Anshuman Khandual wrote:
> >>> But 'page' isn't necessarily PMD-aligned.  I don't think we can rely on
> >>> architectures doing the right thing if asked to make a PMD for a randomly
> >>> aligned page.
> >>>
> >>> How about finding the physical address of something like kernel_init(),
> >>
> >> Physical address corresponding to the symbol in the kernel text segment ?
> > 
> > Yes.  We need the address of something that's definitely memory.
> > The stack might be in vmalloc space.  We can't allocate memory from the
> > allocator that's PUD-aligned.  This seems like a reasonable approximation
> > to something that might work.
> 
> Okay sure. What is about vmalloc space being PUD aligned and how that is
> problematic here ? Could you please give some details. Just being curious.

Those were two different sentences.

We can't use the address of something on the stack, because we don't
know whether the stack is in vmalloc space or in the direct map.

We can't use the address of something we've allocated from the page
allocator, because the page allocator can't give us PUD-aligned memory.

> > I think that's a mistake.  As Russell said, the ARM p*d manipulation
> > functions expect to operate on tables, not on individual entries
> > constructed on the stack.
> 
> Hmm. I assume that it will take care of dual 32 bit entry updates on arm
> platform through various helper functions as Russel had mentioned earlier.
> After we create page table with p?d_alloc() functions and pick an entry at
> each page table level.

Right.

> > So I think the right thing to do here is allocate an mm, then do the
> > pgd_alloc / p4d_alloc / pud_alloc / pmd_alloc / pte_alloc() steps giving
> > you real page tables that you can manipulate.
> > 
> > Then destroy them, of course.  And don't access through them.
> 
> mm_alloc() seems like a comprehensive helper to allocate and initialize a
> mm_struct. But could we use mm_init() with 'current' in the driver context or we
> need to create a dummy task_struct for this purpose. Some initial tests show that
> p?d_alloc() and p?d_free() at each level with a fixed virtual address gives p?d_t
> entries required at various page table level to test upon.

I think it's wise to start a new mm.  I'm not sure exactly what calls
to make to get one going.

> >>>> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> >>>> +static void pud_basic_tests(void)
> >>>
> >>> Is this the right ifdef?
> >>
> >> IIUC THP at PUD is where the pud_t entries are directly operated upon and the
> >> corresponding accessors are present only when HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> >> is enabled. Am I missing something here ?
> > 
> > Maybe I am.  I thought we could end up operating on PUDs for kernel mappings,
> > even without transparent hugepages turned on.
> 
> In generic MM ? IIUC except ioremap mapping all other PUD handling for kernel virtual
> range is platform specific. All the helpers used in the function pud_basic_tests() are
> part of THP and used in mm/huge_memory.c

But what about hugetlbfs?  And vmalloc can also use larger pages these days.
I don't think these tests should be conditional on transparent hugepages.


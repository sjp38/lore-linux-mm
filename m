Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D04B3C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:10:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B595214AE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 23:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BFCdEpjp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B595214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 232858E0003; Mon, 11 Mar 2019 19:10:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E1E28E0002; Mon, 11 Mar 2019 19:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0ABC68E0003; Mon, 11 Mar 2019 19:10:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D581A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 19:10:23 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v3so434222iol.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:10:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=JhWeojvwTBz9Aj5xfVVwnx7e9iYd5cVRUTneoT1n0Xc=;
        b=Drbb8wm4o8dE4pBlmhg317a/epOa17qQPfsvWO7OihNaAk2pJQ+u/Dbfl6w6Cmper7
         Uf6/3ER4wZdwbqEHnK5Rea8+ZW12LPrpSbfWwDhDGFcyvadhzfrn4sHnRciYbIcnCbdH
         0AiG/H6fl7Sok5i0JZh5WhviqQEyX6tR2S3gYwnK6ltF/BSfZQVNpXshSAY5mLMlLx2p
         kQSO8St+jJnvRdj2EgPKDnG3Sp5fpfs5tuRs2kbs9xB7cXIl1bUx5uTj+IUGRl6MFDoE
         8RluAfMD1nQP+Q0XqHlhTjLmRrh0eUNtcOr+gIM7flWBSOyHzgKnppJaTbpC9JI6ngp/
         vuFg==
X-Gm-Message-State: APjAAAUKubgVt3IlSpRsFD8Z12XfDNrYN86dIrMhtEN6DB3YyFzvhxzI
	+iOgFxc9ZCVi3ZPoNaQtRTZ8cF1t4xufqrKwsy+vkBLE54PExeBrLw8N3YnozQkQOYOEDUkzfVX
	U/EipRVQtFxh5DmtS11NA781PqhWRbBMue34K+mhShewlaG/dbryBZQxkwD3RI9QI0xU4Df7Hc0
	Rv2miBwSwjQwM77V3G3UiVWzQr9XaClMsXCQA5L3lBXnYnwfwR3zMEIXZFVJvfk5v7hKFUE0n7m
	MggUq54azaT5mwNt86JUV0k3qsnIwNPtSW6c7/oqHOIox1HXGe03Qd1LKp6SwFORKfsHv/nXKfo
	AasTgCZeo32vdCX/JY48gr+O04Tk0b/icVLHDFfENxz6zd5kK0xcpQXbVa8AaAhtUcQ+OOHSot5
	M
X-Received: by 2002:a6b:dd16:: with SMTP id f22mr18271730ioc.148.1552345823641;
        Mon, 11 Mar 2019 16:10:23 -0700 (PDT)
X-Received: by 2002:a6b:dd16:: with SMTP id f22mr18271694ioc.148.1552345822795;
        Mon, 11 Mar 2019 16:10:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552345822; cv=none;
        d=google.com; s=arc-20160816;
        b=beEzzuhcD3pfcOSuXnM3ikGK80jJ8DQK5xzZP9QpMl/cIcqnaf+azC/JI6y6oME1sf
         ivc7r3h/OgPgne+JYfZnZnTZ6BPKn910mKNZhXVDE7hgzXhwE9JDZlGWrYe+2rMI5aHT
         /+hW4smoHJuhbkImL0TbxCIleYl0GffYVLqYDFtqJ30bzR+SBsKda8WjGepJ8SVgHNXI
         twyzUHferQ+5n4gNURD3Q5X0z/8KuplO2tIwAbqQ73SfhrpQuCpIhUG18urJqbQuWQNR
         jFU6BFOimXF7pJIOzQOOIP+LtpQvqhtJHi/HSJu+9xqtxt4S+dMNbtIQY+5nNlWcZRAr
         otlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=JhWeojvwTBz9Aj5xfVVwnx7e9iYd5cVRUTneoT1n0Xc=;
        b=dDHWYoS6Vic1/1WIUtId5h8qWgL94W3DePpGA2dxBJqJs8WWP/VS0Cv3R0P7IAaJ9y
         JGX9lV3kBA1LCR2e7BhLvWby88uUccUpcInkpaJV4o8dOEBcqIxcFQCba2jRlAHMEy06
         ZupBfXM7Trolo6+NduNhPAT6Rb/8zYOaJksedwlO2aMz7bmcWK1XAH+z8CDQFqICXDrL
         A5pJVNkFE6DX4tiEw917Myip1du7ZeW5GiV9x0v4LHriOvJPJIx9+PWmezWITLkU+mf6
         j4Mpy9yq7NvEZPpR6/rH/trbuSeL/VbgpSzguFqNugZLGU0DgUvXm9RrZmcaU67UjJQK
         9O4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BFCdEpjp;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor1149115itb.5.2019.03.11.16.10.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 16:10:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BFCdEpjp;
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JhWeojvwTBz9Aj5xfVVwnx7e9iYd5cVRUTneoT1n0Xc=;
        b=BFCdEpjpz6/5eZxfAWUzbb7WEdlvYQT0pMsvyKFuhE4KY5Gkq2K/1BymERTER4MfgR
         5FjA4AHs6caoW3r0PP/P70NTh7d8LNawALOlZoikT5heWcO3L+sq/NgyykmapadiSY68
         y5igodO4a2m54Diz5epJvv2vfS/KOXSY/9tgYMYEvv2uGjOxDkH3bWv6GtbT+KPXCNW9
         Gfq1E4YLFi3BBhj/YismuquVQuXKMx8gm5uPl6hxgqmhy2D7QgNy8dyuNAXVRHZNyDTE
         o3G1G8B9ENnfKwHKMVkWktHtvSj+k6OuQymXB8shWe8/011mt4rQJrSAEv/nlImshexE
         2vuw==
X-Google-Smtp-Source: APXvYqx9zcbjCN/V0nVy+yl1+y41Oy1hqNkxzFW0Tj557B/z8cz2nER+NmYJRrM/iVJJLRTq7G+jSw==
X-Received: by 2002:a24:7f04:: with SMTP id r4mr406191itc.17.1552345822341;
        Mon, 11 Mar 2019 16:10:22 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id b202sm357295itb.36.2019.03.11.16.10.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 11 Mar 2019 16:10:21 -0700 (PDT)
Date: Mon, 11 Mar 2019 17:10:17 -0600
From: Yu Zhao <yuzhao@google.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
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
Message-ID: <20190311231017.GA207964@google.com>
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
 <20190310011906.254635-3-yuzhao@google.com>
 <dfc727b4-0806-4867-2f9c-0bb8fdd459ad@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dfc727b4-0806-4867-2f9c-0bb8fdd459ad@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 01:58:27PM +0530, Anshuman Khandual wrote:
> On 03/10/2019 06:49 AM, Yu Zhao wrote:
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
> > 
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
> There is just one problem here. ARM KVM's stage2_pmd_free() calls into pmd_free() on a page
> originally allocated with __get_free_page() and never went through pgtable_pmd_page_ctor().
> So when ARCH_ENABLE_SPLIT_PMD_PTLOCK is enabled
> 
> stage2_pmd_free()
> 	pgtable_pmd_page_dtor()
> 		ptlock_free()
> 			kmem_cache_free(page_ptl_cachep, page->ptl)
> 
> Though SLUB implementation for kmem_cache_free() seems to be handling NULL page->ptl (as the
> page never got it's lock allocated or initialized) correctly I am not sure if it is a right
> thing to do.

Thanks for reminding me. This should be fixed as well. Will do it
in a separate patch.


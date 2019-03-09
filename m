Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5573C43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 03:52:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CBC9207E0
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 03:52:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m9ayY6z/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CBC9207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02B408E0003; Fri,  8 Mar 2019 22:52:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1C078E0002; Fri,  8 Mar 2019 22:52:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE2D68E0003; Fri,  8 Mar 2019 22:52:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B739D8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 22:52:34 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id e9so17078662iob.4
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 19:52:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=m377kZJyLVBelvFNmvVkrDdNPU+nsXM2F8Z21iX0YCQ=;
        b=t+dqpGV+ub3NatZFoazWKHNwM14hbVDFp4sjeJgtAuZnHKRBV4pDYIqDD77lvOpWgL
         dw3FIk6C3eAO5LCxlCEHSUp2e/M2EV5EO2uOogNMmKR8ev4nIzJARTLxbk+glFOiAXXm
         koYIlt7Q8eKDZhXk6cmdpUxlw8NUHUbsZAPFtYx9bvemQmlYRUIvypMeLW8f97o8yXpH
         INLWBjVNMjqxagPBOS+uAdp4KlVsMs3Kp2njlwNVaMfdiUvjgsj69s08gFV5GoGUVN+T
         lnxDpWGvDt9DrhL1WFCkyWIMkB2jdEtW/KdRf/V5aHCCudNqdelpJf1ypFFUoAF0KkyQ
         xJ2w==
X-Gm-Message-State: APjAAAWd1izlUp1V2jioMTznu1QlH2bYvKXi1OpDIFnJuVo9E32AzTTG
	9+6u9Vn1rz4aZMZaqS+uFcZYNaG3QFvEn9EZNibnI+kbOX/dXXeWGrtLY6uuFsgdSrQidwpIj+j
	zlyCxRGmzcdUWAx2+/MvpC7v6bcPb0wnOtlVzyl8HNhYfR56dLAhRQdK+wsQf8pybmnixb29j7V
	Dqw+3O0Zx7tYMRFV/+vsZbYQilGYRDEQOM7FImttPCaCYmbQFp36MmST3OU0MRFWi/FATDAyr/4
	2eDiOt/wKLx1/rS533jFvDcKyCFIl6BXCbxVHd+AP7TXhpqMl84EYCoNRy2niSfsj2RHAgy6llj
	fj+kZhB3BwhKMbqSvXbeJtH7gX8yM/kQDR5H2AkbtuI+kNuZaz8429KsDyL1Mc9tkpvh+bmCu0V
	p
X-Received: by 2002:a24:908:: with SMTP id 8mr10266850itm.155.1552103554423;
        Fri, 08 Mar 2019 19:52:34 -0800 (PST)
X-Received: by 2002:a24:908:: with SMTP id 8mr10266829itm.155.1552103553431;
        Fri, 08 Mar 2019 19:52:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552103553; cv=none;
        d=google.com; s=arc-20160816;
        b=m3XDH0fKk9WOprO9GynNuHYHQYT15EXStFQ1gy6p+9Fguh3koojkk29GKVMUXMbKSP
         +RoC4YzGYqHQTUQdtN3F1oZA5DrcH4ahkhNerOg5yKD/Mxa8nWMZlbc/MNW+Pl0LCMWY
         +HmiEsv1hOocVgZ5LSYQI1YDBa9dhI6TorsfBVxINTx5voMXPDWI/Bk6EvuT/uU7jhPY
         2LNs0SGnj0taWrtxA8Zhia9aVUiBO5jmGimvL80D67EvNBBcckg10tPbzW6oNixswVtX
         1qL9eYbVdrl3lN4SHfBNeKxDO07hvPCrVB4I1GRAX7BNqvSrzHqKPG4f1Wu6AK1TFEK3
         IbQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=m377kZJyLVBelvFNmvVkrDdNPU+nsXM2F8Z21iX0YCQ=;
        b=Qg1Aht2ySXYJqeticKGS2IaBR55JU7tJ4oikCKzO1KR+ghrYQK2FNStGGUxJVnEO8s
         t/jt1qkOg6H+BLI9LkktBNeQjGXzf45XbfsNoKSI30JV9wON1UrBFVdUson9MkDJ1MgH
         tpi/dnSGbrkvnWNS3r7NGyaBJrtQ5Ruu6653ySNoXvShX+zHWIC0fjBUkwH9BCu7l7pA
         klDEbRs3vigmbsUcpPwBl4mgyRAOE7flGahGi9IF6vprBzqENffUuskRG+/On9AnbRfb
         j0auap9Ihi/y0HEUEM3dstqPIOQOTnYt06vn3UWrhrC9O/x2JjuUC8BNJc2gnWC/8xC+
         G+Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="m9ayY6z/";
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g77sor6064360itg.0.2019.03.08.19.52.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 19:52:33 -0800 (PST)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="m9ayY6z/";
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=m377kZJyLVBelvFNmvVkrDdNPU+nsXM2F8Z21iX0YCQ=;
        b=m9ayY6z/EzLJdpsqf0ARQ566h+fNvCK43sc+5RsrKitBH7l5IJYnyxlVcknqGnusWm
         8TImiEA0X5wRp3f/WwfSofXpUBq0c3qgw+Y2wFaZBQo7LBl8E74BezC+JelThr8zR9vI
         eXsReEoRW6yjw4vwYV/ysGsz0oWGP+YtMAAiWcGOt7mJ0iXbuQSf2Wu3fxyQlrCRfrc7
         Gfoe6yYd2LjcztJi7lssLpYsp5FbeuckI6Y8DKDyuD52nfWkYUyh6Y6MPW3tDGMcTlN3
         PjT4U5nwWQ9kNQTSwfKeomhDAc+f1VEWOnQICfQTktrA3mtrIZUZdNq7nVaUtDirbyXF
         xRrw==
X-Google-Smtp-Source: APXvYqwCbLxEH0MAwR0zOVXRARtteHVK25Cgv6im4wYGYLl/7gE17TQQw41o7bgV8bkBqOTUfLBQwQ==
X-Received: by 2002:a24:38f:: with SMTP id e137mr8855070ite.99.1552103552925;
        Fri, 08 Mar 2019 19:52:32 -0800 (PST)
Received: from google.com ([2620:15c:183:0:a0c3:519e:9276:fc96])
        by smtp.gmail.com with ESMTPSA id n4sm3928063ioa.26.2019.03.08.19.52.31
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 08 Mar 2019 19:52:32 -0800 (PST)
Date: Fri, 8 Mar 2019 20:52:27 -0700
From: Yu Zhao <yuzhao@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
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
Subject: Re: [PATCH v2 2/3] arm64: mm: don't call page table ctors for init_mm
Message-ID: <20190309035227.GA214016@google.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <20190218231319.178224-2-yuzhao@google.com>
 <20190226151307.GB20230@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226151307.GB20230@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 03:13:07PM +0000, Mark Rutland wrote:
> Hi,
> 
> On Mon, Feb 18, 2019 at 04:13:18PM -0700, Yu Zhao wrote:
> > init_mm doesn't require page table lock to be initialized at
> > any level. Add a separate page table allocator for it, and the
> > new one skips page table ctors.
> 
> Just to check, in a previous reply you mentioned we need to call the
> ctors for our efi_mm, since we use apply_to_page_range() on that. Is
> that only because apply_to_pte_range() tries to take the ptl for non
> init_mm?

Precisely.

> ... or did I miss something else?
> 
> > The ctors allocate memory when ALLOC_SPLIT_PTLOCKS is set. Not
> > calling them avoids memory leak in case we call pte_free_kernel()
> > on init_mm.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> 
> Assuming that was all, this patch makes sense to me. FWIW:
> 
> Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks.

> Thanks,
> Mark.
> 
> > ---
> >  arch/arm64/mm/mmu.c | 15 +++++++++++++--
> >  1 file changed, 13 insertions(+), 2 deletions(-)
> > 
> > diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> > index fa7351877af3..e8bf8a6300e8 100644
> > --- a/arch/arm64/mm/mmu.c
> > +++ b/arch/arm64/mm/mmu.c
> > @@ -370,6 +370,16 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
> >  	} while (pgdp++, addr = next, addr != end);
> >  }
> >  
> > +static phys_addr_t pgd_kernel_pgtable_alloc(int shift)
> > +{
> > +	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> > +	BUG_ON(!ptr);
> > +
> > +	/* Ensure the zeroed page is visible to the page table walker */
> > +	dsb(ishst);
> > +	return __pa(ptr);
> > +}
> > +
> >  static phys_addr_t pgd_pgtable_alloc(int shift)
> >  {
> >  	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> > @@ -591,7 +601,7 @@ static int __init map_entry_trampoline(void)
> >  	/* Map only the text into the trampoline page table */
> >  	memset(tramp_pg_dir, 0, PGD_SIZE);
> >  	__create_pgd_mapping(tramp_pg_dir, pa_start, TRAMP_VALIAS, PAGE_SIZE,
> > -			     prot, pgd_pgtable_alloc, 0);
> > +			     prot, pgd_kernel_pgtable_alloc, 0);
> >  
> >  	/* Map both the text and data into the kernel page table */
> >  	__set_fixmap(FIX_ENTRY_TRAMP_TEXT, pa_start, prot);
> > @@ -1067,7 +1077,8 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
> >  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
> >  
> >  	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
> > -			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
> > +			     size, PAGE_KERNEL, pgd_kernel_pgtable_alloc,
> > +			     flags);
> >  
> >  	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> >  			   altmap, want_memblock);
> > -- 
> > 2.21.0.rc0.258.g878e2cd30e-goog
> > 


Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9DDDC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 710EE21479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:00:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s/6Ba07D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 710EE21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F214B6B0006; Mon, 20 May 2019 19:00:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1446B0007; Mon, 20 May 2019 19:00:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D98C06B0008; Mon, 20 May 2019 19:00:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A0C5A6B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 19:00:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s5so10674204pgv.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 16:00:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=14OretOU5ipUcLEuT7rLji+Wv0tITSxaTbRALv2BYJU=;
        b=roypyXKO+tQX2X1017ohpoJ8wiW7NDPAufmq+A4/ALTyT4FU3GjSIfVYleiIZfSkQ3
         PQfI7ikp9g2PEeg8WY4zxPatHm9MzReicZPb0LixJEQgZ0GgxXqKxqPrDEv3x5eUT73V
         /41KxJ1n1QNsNeYfoRjwSj/Ew/yqMcPHXInB5Hfcste/TCbRyHR4FnY6vqnnZb39u1VC
         SmINcZsr+ZBZAShd5aM/p0WurMZ4XR24LsgGRxTpUtg3X75puxSrAdqUg12YSmD/hoUO
         VYHSKrf7TmnBeSXrmOE5jsK+cSpzYJ4XbWRwDqJBjASkjKD5HVmcq0AXUlB4b39WBLGV
         bUjQ==
X-Gm-Message-State: APjAAAUj57izHGjgx4+6Ft2jwB4ImutEO6ES3XdYPtFBUzvlFHHFOb+b
	V4qzdhKSm4skZLbjRX/yUHevcHByrrgpcmQD3bShd1GS9Wh82ojkJ1XYjRObOW4e+Hs7qMPJN0r
	tD0shZOQR/NI15cznM/YXG/lTSvz+559JMEDKPJtEn1s3hVd/LKVw11oP+hfuHys=
X-Received: by 2002:a17:902:9007:: with SMTP id a7mr77622387plp.221.1558393246216;
        Mon, 20 May 2019 16:00:46 -0700 (PDT)
X-Received: by 2002:a17:902:9007:: with SMTP id a7mr77622308plp.221.1558393245356;
        Mon, 20 May 2019 16:00:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558393245; cv=none;
        d=google.com; s=arc-20160816;
        b=PrASo7wDjXrmbxMQD+f4VK2BB2TDnSA4A4azB9E+Ye37MK+Pin93E2Z76FlWfPcF9A
         84yjrMKI5EXW+IehMJ2UMl/agV+Z3oizWK6kwgeIuzW7POQtMZETHtS+owzCXC+9pdiD
         Ofjcpm+n3F5Qmo3cF2lses9mogKbPKEYSEsJXE+m2q7iuD6rcRyDIxV00AvYq1dlszrp
         BmAOLalc+Zz1rDWTbg8B1MRfTAhowwtB4nkhuCPiJIqYwwIsGpq7efAWR7v/0U9NBWeC
         leT66EnTBf1PGg2YOtYU7BJpSk3ozPmrOyVA0PTPsOlsNCdJhuL00RAqbMyINTTT+VYp
         TiCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=14OretOU5ipUcLEuT7rLji+Wv0tITSxaTbRALv2BYJU=;
        b=mPFtkW777ANy1rX+UHshCTxloqmYyhSB+Sf21YuGXhVxZiClDr6zsqFyEHiXFNS4mw
         qLIAnvZlkmXh9Rdp+p3Hg22U0VOaNFy54+1syVcqloPMTIthyoD8vRCvjk9Uv6p+1dAb
         Q/P8upJ2ERNFzBRPxfSKyefOKXNGtHdDNAQnuMY64Lx4WAYGjXheASBrAQRqtWP5h4NX
         XbqEH1kdewJLU1k4QVNN5CZ5ihsg3XkIpGqjaq7eGpoDndlQGuiqLAwb0JXINyghslxM
         utoushGEM8WVnhWU4FmBEVaShppc54EmkaG7QlnQwZyeGlTDiQspyNY50bCqc4/Cplms
         m0SA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="s/6Ba07D";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5sor19210239pgw.13.2019.05.20.16.00.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 16:00:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="s/6Ba07D";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=14OretOU5ipUcLEuT7rLji+Wv0tITSxaTbRALv2BYJU=;
        b=s/6Ba07Du0GM/eBHid2PM64mJOAPVhS2AQFxuMRkuxXaVVaUF7jUNvzCY9j4jrvtLa
         ZBSLBfSk3lEsP2K9LJSRhD087itqoDf2gm2LrIStZkbXXzi1km4iIknMALxVDvpI9BkW
         mqp/jpulVqzejTGmK4XvylGX2e/rqdK2d9ZIILqvL4UTwPqcaJR87vIvohObrV0FfRLj
         R5Xh9K9veerDfYMJ6xzG/tlIW2p0OHL3nsEX5TdC3FsvmK98iR8ViijbCa8XdySXxPNk
         QaQKmscloJBA+lpCl+HuJcYOsP8E1zI3PmHINz8qbP21WnhoUh9bOWAEZGpCCdKSkyC1
         0QLQ==
X-Google-Smtp-Source: APXvYqwlCwv6iVt8qa4j7b5TNvEw9bZfLYV97XhCwcJ2kySvzUYz1Edq9V5cLMHIvd7IezTZ2SqKPA==
X-Received: by 2002:a63:5fcc:: with SMTP id t195mr16800007pgb.120.1558393244797;
        Mon, 20 May 2019 16:00:44 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id g9sm18206791pgs.78.2019.05.20.16.00.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 16:00:43 -0700 (PDT)
Date: Tue, 21 May 2019 08:00:38 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 3/7] mm: introduce MADV_COLD
Message-ID: <20190520230038.GD10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-4-minchan@kernel.org>
 <20190520082703.GX6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520082703.GX6836@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 10:27:03AM +0200, Michal Hocko wrote:
> [Cc linux-api]
> 
> On Mon 20-05-19 12:52:50, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range
> > for a long time, it could hint kernel that the pages can be
> > reclaimed instantly but data should be preserved for future use.
> > This could reduce workingset eviction so it ends up increasing
> > performance.
> > 
> > This patch introduces the new MADV_COLD hint to madvise(2)
> > syscall. MADV_COLD can be used by a process to mark a memory range
> > as not expected to be used for a long time. The hint can help
> > kernel in deciding which pages to evict proactively.
> 
> As mentioned in other email this looks like a non-destructive
> MADV_DONTNEED alternative.
> 
> > Internally, it works via reclaiming memory in process context
> > the syscall is called. If the page is dirty but backing storage
> > is not synchronous device, the written page will be rotate back
> > into LRU's tail once the write is done so they will reclaim easily
> > when memory pressure happens. If backing storage is
> > synchrnous device(e.g., zram), hte page will be reclaimed instantly.
> 
> Why do we special case async backing storage? Please always try to
> explain _why_ the decision is made.

I didn't make any decesion. ;-) That's how current reclaim works to
avoid latency of freeing page in interrupt context. I had a patchset
to resolve the concern a few years ago but got distracted.

> 
> I haven't checked the implementation yet so I cannot comment on that.
> 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/swap.h                   |   1 +
> >  include/uapi/asm-generic/mman-common.h |   1 +
> >  mm/madvise.c                           | 123 +++++++++++++++++++++++++
> >  mm/vmscan.c                            |  74 +++++++++++++++
> >  4 files changed, 199 insertions(+)
> > 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 64795abea003..7f32a948fc6a 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -365,6 +365,7 @@ extern int vm_swappiness;
> >  extern int remove_mapping(struct address_space *mapping, struct page *page);
> >  extern unsigned long vm_total_pages;
> >  
> > +extern unsigned long reclaim_pages(struct list_head *page_list);
> >  #ifdef CONFIG_NUMA
> >  extern int node_reclaim_mode;
> >  extern int sysctl_min_unmapped_ratio;
> > diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> > index f7a4a5d4b642..b9b51eeb8e1a 100644
> > --- a/include/uapi/asm-generic/mman-common.h
> > +++ b/include/uapi/asm-generic/mman-common.h
> > @@ -43,6 +43,7 @@
> >  #define MADV_WILLNEED	3		/* will need these pages */
> >  #define MADV_DONTNEED	4		/* don't need these pages */
> >  #define MADV_COOL	5		/* deactivatie these pages */
> > +#define MADV_COLD	6		/* reclaim these pages */
> >  
> >  /* common parameters: try to keep these consistent across architectures */
> >  #define MADV_FREE	8		/* free pages only if memory pressure */
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index c05817fb570d..9a6698b56845 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -42,6 +42,7 @@ static int madvise_need_mmap_write(int behavior)
> >  	case MADV_WILLNEED:
> >  	case MADV_DONTNEED:
> >  	case MADV_COOL:
> > +	case MADV_COLD:
> >  	case MADV_FREE:
> >  		return 0;
> >  	default:
> > @@ -416,6 +417,125 @@ static long madvise_cool(struct vm_area_struct *vma,
> >  	return 0;
> >  }
> >  
> > +static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> > +{
> > +	pte_t *orig_pte, *pte, ptent;
> > +	spinlock_t *ptl;
> > +	LIST_HEAD(page_list);
> > +	struct page *page;
> > +	int isolated = 0;
> > +	struct vm_area_struct *vma = walk->vma;
> > +	unsigned long next;
> > +
> > +	next = pmd_addr_end(addr, end);
> > +	if (pmd_trans_huge(*pmd)) {
> > +		spinlock_t *ptl;
> > +
> > +		ptl = pmd_trans_huge_lock(pmd, vma);
> > +		if (!ptl)
> > +			return 0;
> > +
> > +		if (is_huge_zero_pmd(*pmd))
> > +			goto huge_unlock;
> > +
> > +		page = pmd_page(*pmd);
> > +		if (page_mapcount(page) > 1)
> > +			goto huge_unlock;
> > +
> > +		if (next - addr != HPAGE_PMD_SIZE) {
> > +			int err;
> > +
> > +			get_page(page);
> > +			spin_unlock(ptl);
> > +			lock_page(page);
> > +			err = split_huge_page(page);
> > +			unlock_page(page);
> > +			put_page(page);
> > +			if (!err)
> > +				goto regular_page;
> > +			return 0;
> > +		}
> > +
> > +		if (isolate_lru_page(page))
> > +			goto huge_unlock;
> > +
> > +		list_add(&page->lru, &page_list);
> > +huge_unlock:
> > +		spin_unlock(ptl);
> > +		reclaim_pages(&page_list);
> > +		return 0;
> > +	}
> > +
> > +	if (pmd_trans_unstable(pmd))
> > +		return 0;
> > +regular_page:
> > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> > +		ptent = *pte;
> > +		if (!pte_present(ptent))
> > +			continue;
> > +
> > +		page = vm_normal_page(vma, addr, ptent);
> > +		if (!page)
> > +			continue;
> > +
> > +		if (page_mapcount(page) > 1)
> > +			continue;
> > +
> > +		if (isolate_lru_page(page))
> > +			continue;
> > +
> > +		isolated++;
> > +		list_add(&page->lru, &page_list);
> > +		if (isolated >= SWAP_CLUSTER_MAX) {
> > +			pte_unmap_unlock(orig_pte, ptl);
> > +			reclaim_pages(&page_list);
> > +			isolated = 0;
> > +			pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +			orig_pte = pte;
> > +		}
> > +	}
> > +
> > +	pte_unmap_unlock(orig_pte, ptl);
> > +	reclaim_pages(&page_list);
> > +	cond_resched();
> > +
> > +	return 0;
> > +}
> > +
> > +static void madvise_cold_page_range(struct mmu_gather *tlb,
> > +			     struct vm_area_struct *vma,
> > +			     unsigned long addr, unsigned long end)
> > +{
> > +	struct mm_walk warm_walk = {
> > +		.pmd_entry = madvise_cold_pte_range,
> > +		.mm = vma->vm_mm,
> > +	};
> > +
> > +	tlb_start_vma(tlb, vma);
> > +	walk_page_range(addr, end, &warm_walk);
> > +	tlb_end_vma(tlb, vma);
> > +}
> > +
> > +
> > +static long madvise_cold(struct vm_area_struct *vma,
> > +			unsigned long start_addr, unsigned long end_addr)
> > +{
> > +	struct mm_struct *mm = vma->vm_mm;
> > +	struct mmu_gather tlb;
> > +
> > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > +		return -EINVAL;
> > +
> > +	lru_add_drain();
> > +	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> > +	madvise_cold_page_range(&tlb, vma, start_addr, end_addr);
> > +	tlb_finish_mmu(&tlb, start_addr, end_addr);
> > +
> > +	return 0;
> > +}
> > +
> >  static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  				unsigned long end, struct mm_walk *walk)
> >  
> > @@ -806,6 +926,8 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> >  		return madvise_willneed(vma, prev, start, end);
> >  	case MADV_COOL:
> >  		return madvise_cool(vma, start, end);
> > +	case MADV_COLD:
> > +		return madvise_cold(vma, start, end);
> >  	case MADV_FREE:
> >  	case MADV_DONTNEED:
> >  		return madvise_dontneed_free(vma, prev, start, end, behavior);
> > @@ -828,6 +950,7 @@ madvise_behavior_valid(int behavior)
> >  	case MADV_DONTNEED:
> >  	case MADV_FREE:
> >  	case MADV_COOL:
> > +	case MADV_COLD:
> >  #ifdef CONFIG_KSM
> >  	case MADV_MERGEABLE:
> >  	case MADV_UNMERGEABLE:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a28e5d17b495..1701b31f70a8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2096,6 +2096,80 @@ static void shrink_active_list(unsigned long nr_to_scan,
> >  			nr_deactivate, nr_rotated, sc->priority, file);
> >  }
> >  
> > +unsigned long reclaim_pages(struct list_head *page_list)
> > +{
> > +	int nid = -1;
> > +	unsigned long nr_isolated[2] = {0, };
> > +	unsigned long nr_reclaimed = 0;
> > +	LIST_HEAD(node_page_list);
> > +	struct reclaim_stat dummy_stat;
> > +	struct scan_control sc = {
> > +		.gfp_mask = GFP_KERNEL,
> > +		.priority = DEF_PRIORITY,
> > +		.may_writepage = 1,
> > +		.may_unmap = 1,
> > +		.may_swap = 1,
> > +	};
> > +
> > +	while (!list_empty(page_list)) {
> > +		struct page *page;
> > +
> > +		page = lru_to_page(page_list);
> > +		list_del(&page->lru);
> > +
> > +		if (nid == -1) {
> > +			nid = page_to_nid(page);
> > +			INIT_LIST_HEAD(&node_page_list);
> > +			nr_isolated[0] = nr_isolated[1] = 0;
> > +		}
> > +
> > +		if (nid == page_to_nid(page)) {
> > +			list_add(&page->lru, &node_page_list);
> > +			nr_isolated[!!page_is_file_cache(page)] +=
> > +						hpage_nr_pages(page);
> > +			continue;
> > +		}
> > +
> > +		nid = page_to_nid(page);
> > +
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					nr_isolated[1]);
> > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> > +				&dummy_stat, true);
> > +		while (!list_empty(&node_page_list)) {
> > +			struct page *page = lru_to_page(page_list);
> > +
> > +			list_del(&page->lru);
> > +			putback_lru_page(page);
> > +		}
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					-nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					-nr_isolated[1]);
> > +		nr_isolated[0] = nr_isolated[1] = 0;
> > +		INIT_LIST_HEAD(&node_page_list);
> > +	}
> > +
> > +	if (!list_empty(&node_page_list)) {
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					nr_isolated[1]);
> > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > +				NODE_DATA(nid), &sc, TTU_IGNORE_ACCESS,
> > +				&dummy_stat, true);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_ANON,
> > +					-nr_isolated[0]);
> > +		mod_node_page_state(NODE_DATA(nid), NR_ISOLATED_FILE,
> > +					-nr_isolated[1]);
> > +	}
> > +
> > +	return nr_reclaimed;
> > +}
> > +
> >  /*
> >   * The inactive anon list should be small enough that the VM never has
> >   * to do too much work.
> > -- 
> > 2.21.0.1020.gf2820cf01a-goog
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs


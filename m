Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7244CC73C66
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:11:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4BA2214AE
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 23:11:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A+C44U4G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4BA2214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EDD56B0003; Sun, 14 Jul 2019 19:11:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49D396B0006; Sun, 14 Jul 2019 19:11:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 340056B0007; Sun, 14 Jul 2019 19:11:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDCB26B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 19:11:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 145so9378734pfv.18
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 16:11:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QprZyTVrRGOU97hs8P2pLED7gdEo6Bn7w3dBtOXj1PI=;
        b=MOLTrK6D2Js/BF1ZrtTYJMLIUD0+T5g8Mu59sIGB2cmfL07RX6QG94F+komra841MZ
         E4gQ14WLbc760uaUGcym+6khJP64hZhCrhGUwpchnCiuN1uMb2rjPdYiGiQBIqIACYYj
         /gnXihFmXcpRTRGcaH6FzlLP7u9v005Oy/HIzY/LRv101br9oA4K5VYxsbOJv4/EUGUK
         vs3i6fo/bD9X8+qY23Lw68ObGJeKaTKmBFqVMVNeKuZjaOLjnj6vWLsTkL3eCouUzE0C
         gtrGNfdATm9EcqiJzSkBrni4lK/K0Wqi+v6Stg+QbIToGlFcCe9XjfJGQhOpIFLF9XLP
         b4yQ==
X-Gm-Message-State: APjAAAUWRNRjsxvpUXFIOihdbYY+s33z3wl/styfCxZglZRiOx5r8Vpc
	cMvk2qCXDBRW5orpj3Jvm4anPwfY7rGFboJtXo7jStvgcB/HBgiOo7JwpPv2yHlkEHFfq3uPnzh
	a+v2RCz5zm02DhkdjlsaZ9t3IbasYGkp19DITHuN2SNdhwi2ZkygGxUN+RUAiAW8=
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr24572864plb.26.1563145913499;
        Sun, 14 Jul 2019 16:11:53 -0700 (PDT)
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr24572822plb.26.1563145912597;
        Sun, 14 Jul 2019 16:11:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563145912; cv=none;
        d=google.com; s=arc-20160816;
        b=n9drv1Da6mS9NkC8pXBnev9esUyrWz2gVyV+OndS0KqJM3ULuCED889HgiQTUjDFcl
         1wCylUphfDppPasYvJ8/4vzbPVG2nqrEKsJNavDEjUQs4hJHhrcw/tcHfhYEGKTsycNd
         2b7FQUQlX2lQAdDpYQa5M80P9MBqppNd1fa8+FcU3J1ZZD12KiIt5Hx1xJtUByJwlE/r
         X/tKyT37Cx/NAwSet8Sl7ETLd6PdMy6JCb4DejGSxhTy9+j/QJ7IKmXhAFnuvecQ93En
         EeiwOfQWzc3WIKjXH2V/6ZmB4gd1VfjrTg2z3+ABw9B+Y2lEZn6A8WOKqV2TD5pL3sml
         mpHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=QprZyTVrRGOU97hs8P2pLED7gdEo6Bn7w3dBtOXj1PI=;
        b=blNbaOw+C7hrECbANq9IrOI6Mj6CCU2Dt+qOHZdkR7cFvdy0lao8Zn61WJY4oDBwFz
         Auddp/NBvjhbhDRbio5jfbMpckMR6UGga9fsd+HfMQLZ9FOEoqBll5V4d7PHq/cSZvFw
         LuRqJvmZiCyV3uDXGVo6iVEmmIK7XhDOA+WN8HUIAp9Wao5XxM+8Dx6X2UJNzGYavgP9
         BnS7a8IY2kezi90AJ2GzTEFZ89km9rlI8/cXVDxB0++Gc6NOitxY5lXYydHQ3BfNEyun
         i9s/lHjAP6ympknL58fJF94WfhGa/djAj2ErzPeBV0Se8pudecI3tYm5awTiS3g+HSTp
         VW4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A+C44U4G;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cp19sor18972397plb.63.2019.07.14.16.11.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 16:11:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=A+C44U4G;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QprZyTVrRGOU97hs8P2pLED7gdEo6Bn7w3dBtOXj1PI=;
        b=A+C44U4GHiHGQET3tLkpB31RD4wI6fK5Vo1rnT8BcbP+YePUM/RwDLOppKtpT48bQh
         dxrFo9S5oW64hvrbSIZ7HjmyHRxW4LE5TY+bqLOjfjjd0c9MauojzUsXK30QjZhshJhK
         tS4TpbLjnw0AgnEkAf90FdNebDnuacYZaEn2NZ1tdnfHCuXQkOLG9g3H8BBR50IW0Dyk
         aDP1nW3xQeCzrAtrSJBTRl3Tu99vC2S7j0uFKH6weRrUWJlmz9HOjg7szu/TB8C0PdZz
         OjtB+Q365C6wqGTtJ3ZmP4hkT5SfsLd5dljivGfZYl9nOkuE+znhjyUEOU4aans/SIlZ
         KkGQ==
X-Google-Smtp-Source: APXvYqypZw9mo80LT1uOMkB/Sw/PUijB4++K7mDpQ5pbZT2o2JA6JmrC4ChRGzaRJHFg4RAUqIbugg==
X-Received: by 2002:a17:902:1e6:: with SMTP id b93mr24790653plb.295.1563145911990;
        Sun, 14 Jul 2019 16:11:51 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id s6sm22459338pfs.122.2019.07.14.16.11.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 14 Jul 2019 16:11:50 -0700 (PDT)
Date: Mon, 15 Jul 2019 08:11:44 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v4 4/4] mm: introduce MADV_PAGEOUT
Message-ID: <20190714231144.GB128252@google.com>
References: <20190711012528.176050-1-minchan@kernel.org>
 <20190711012528.176050-5-minchan@kernel.org>
 <20190711184223.GD20341@cmpxchg.org>
 <20190712051828.GA128252@google.com>
 <20190712135809.GB31107@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190712135809.GB31107@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 09:58:09AM -0400, Johannes Weiner wrote:
> On Fri, Jul 12, 2019 at 02:18:28PM +0900, Minchan Kim wrote:
> > Hi Johannes,
> > 
> > On Thu, Jul 11, 2019 at 02:42:23PM -0400, Johannes Weiner wrote:
> > > On Thu, Jul 11, 2019 at 10:25:28AM +0900, Minchan Kim wrote:
> > > > @@ -480,6 +482,198 @@ static long madvise_cold(struct vm_area_struct *vma,
> > > >  	return 0;
> > > >  }
> > > >  
> > > > +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> > > > +				unsigned long end, struct mm_walk *walk)
> > > > +{
> > > > +	struct mmu_gather *tlb = walk->private;
> > > > +	struct mm_struct *mm = tlb->mm;
> > > > +	struct vm_area_struct *vma = walk->vma;
> > > > +	pte_t *orig_pte, *pte, ptent;
> > > > +	spinlock_t *ptl;
> > > > +	LIST_HEAD(page_list);
> > > > +	struct page *page;
> > > > +	unsigned long next;
> > > > +
> > > > +	if (fatal_signal_pending(current))
> > > > +		return -EINTR;
> > > > +
> > > > +	next = pmd_addr_end(addr, end);
> > > > +	if (pmd_trans_huge(*pmd)) {
> > > > +		pmd_t orig_pmd;
> > > > +
> > > > +		tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
> > > > +		ptl = pmd_trans_huge_lock(pmd, vma);
> > > > +		if (!ptl)
> > > > +			return 0;
> > > > +
> > > > +		orig_pmd = *pmd;
> > > > +		if (is_huge_zero_pmd(orig_pmd))
> > > > +			goto huge_unlock;
> > > > +
> > > > +		if (unlikely(!pmd_present(orig_pmd))) {
> > > > +			VM_BUG_ON(thp_migration_supported() &&
> > > > +					!is_pmd_migration_entry(orig_pmd));
> > > > +			goto huge_unlock;
> > > > +		}
> > > > +
> > > > +		page = pmd_page(orig_pmd);
> > > > +		if (next - addr != HPAGE_PMD_SIZE) {
> > > > +			int err;
> > > > +
> > > > +			if (page_mapcount(page) != 1)
> > > > +				goto huge_unlock;
> > > > +			get_page(page);
> > > > +			spin_unlock(ptl);
> > > > +			lock_page(page);
> > > > +			err = split_huge_page(page);
> > > > +			unlock_page(page);
> > > > +			put_page(page);
> > > > +			if (!err)
> > > > +				goto regular_page;
> > > > +			return 0;
> > > > +		}
> > > > +
> > > > +		if (isolate_lru_page(page))
> > > > +			goto huge_unlock;
> > > > +
> > > > +		if (pmd_young(orig_pmd)) {
> > > > +			pmdp_invalidate(vma, addr, pmd);
> > > > +			orig_pmd = pmd_mkold(orig_pmd);
> > > > +
> > > > +			set_pmd_at(mm, addr, pmd, orig_pmd);
> > > > +			tlb_remove_tlb_entry(tlb, pmd, addr);
> > > > +		}
> > > > +
> > > > +		ClearPageReferenced(page);
> > > > +		test_and_clear_page_young(page);
> > > > +		list_add(&page->lru, &page_list);
> > > > +huge_unlock:
> > > > +		spin_unlock(ptl);
> > > > +		reclaim_pages(&page_list);
> > > > +		return 0;
> > > > +	}
> > > > +
> > > > +	if (pmd_trans_unstable(pmd))
> > > > +		return 0;
> > > > +regular_page:
> > > > +	tlb_change_page_size(tlb, PAGE_SIZE);
> > > > +	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > +	flush_tlb_batched_pending(mm);
> > > > +	arch_enter_lazy_mmu_mode();
> > > > +	for (; addr < end; pte++, addr += PAGE_SIZE) {
> > > > +		ptent = *pte;
> > > > +		if (!pte_present(ptent))
> > > > +			continue;
> > > > +
> > > > +		page = vm_normal_page(vma, addr, ptent);
> > > > +		if (!page)
> > > > +			continue;
> > > > +
> > > > +		/*
> > > > +		 * creating a THP page is expensive so split it only if we
> > > > +		 * are sure it's worth. Split it if we are only owner.
> > > > +		 */
> > > > +		if (PageTransCompound(page)) {
> > > > +			if (page_mapcount(page) != 1)
> > > > +				break;
> > > > +			get_page(page);
> > > > +			if (!trylock_page(page)) {
> > > > +				put_page(page);
> > > > +				break;
> > > > +			}
> > > > +			pte_unmap_unlock(orig_pte, ptl);
> > > > +			if (split_huge_page(page)) {
> > > > +				unlock_page(page);
> > > > +				put_page(page);
> > > > +				pte_offset_map_lock(mm, pmd, addr, &ptl);
> > > > +				break;
> > > > +			}
> > > > +			unlock_page(page);
> > > > +			put_page(page);
> > > > +			pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > > > +			pte--;
> > > > +			addr -= PAGE_SIZE;
> > > > +			continue;
> > > > +		}
> > > > +
> > > > +		VM_BUG_ON_PAGE(PageTransCompound(page), page);
> > > > +
> > > > +		if (isolate_lru_page(page))
> > > > +			continue;
> > > > +
> > > > +		if (pte_young(ptent)) {
> > > > +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> > > > +							tlb->fullmm);
> > > > +			ptent = pte_mkold(ptent);
> > > > +			set_pte_at(mm, addr, pte, ptent);
> > > > +			tlb_remove_tlb_entry(tlb, pte, addr);
> > > > +		}
> > > > +		ClearPageReferenced(page);
> > > > +		test_and_clear_page_young(page);
> > > > +		list_add(&page->lru, &page_list);
> > > > +	}
> > > > +
> > > > +	arch_leave_lazy_mmu_mode();
> > > > +	pte_unmap_unlock(orig_pte, ptl);
> > > > +	reclaim_pages(&page_list);
> > > > +	cond_resched();
> > > > +
> > > > +	return 0;
> > > > +}
> > > 
> > > I know you have briefly talked about code sharing already.
> > > 
> > > While I agree that sharing with MADV_FREE is maybe a stretch, I
> > > applied these patches and compared the pageout and the cold page table
> > > functions, and they are line for line the same EXCEPT for 2-3 lines at
> > > the very end, where one reclaims and the other deactivates. It would
> > > be good to share here, it shouldn't be hard or result in fragile code.
> > 
> > Fair enough if we leave MADV_FREE.
> > 
> > > 
> > > Something like int madvise_cold_or_pageout_range(..., bool pageout)?
> > 
> > How about this?
> > 
> > From 41592f23e876ec21e49dc3c76dc89538e2bb16be Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Fri, 12 Jul 2019 14:05:36 +0900
> > Subject: [PATCH] mm: factor out common parts between MADV_COLD and
> >  MADV_PAGEOUT
> > 
> > There are many common parts between MADV_COLD and MADV_PAGEOUT.
> > This patch factor them out to save code duplication.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> This looks much better, thanks!
> 
> > @@ -423,6 +445,12 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> >  
> >  		VM_BUG_ON_PAGE(PageTransCompound(page), page);
> >  
> > +		if (pageout) {
> > +			if (isolate_lru_page(page))
> > +				continue;
> > +			list_add(&page->lru, &page_list);
> > +		}
> > +
> >  		if (pte_young(ptent)) {
> >  			ptent = ptep_get_and_clear_full(mm, addr, pte,
> >  							tlb->fullmm);
> 
> One thought on the ordering here.
> 
> When LRU isolation fails, it would still make sense to clear the young
> bit: we cannot reclaim the page as we wanted to, but the user still
> provided a clear hint that the page is cold and she won't be touching
> it for a while. MADV_PAGEOUT is basically MADV_COLD + try_to_reclaim.
> So IMO isolation should go to the end next to deactivate_page().

Sure, I will modify MADV_PAGEOUT patch instead of refactoring one.
Thanks for the review, Johannes!


Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBC1EC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:53:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FBD42075C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:53:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FBD42075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8A8C6B0272; Tue, 28 May 2019 04:53:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E61286B0273; Tue, 28 May 2019 04:53:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D76786B0275; Tue, 28 May 2019 04:53:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B78176B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:53:20 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id n10so1710623ita.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:53:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=JsTBwFuSvyYr2hB5/vQwbJjTPwMQasYFW0RoqvTjdms=;
        b=d2NGNsCMJuaFedoJR9FkTsEKQ5zdPa8qCPWMTA087jX4083tNW829Mm9UW1KhhdqqH
         /H/KXlF1Hl+SX+zDtgBl/cLkisNO/7YCM6mVX73pnKFbbqRdyM/cXuS8vzZP1lei8Ymv
         RpShnBH61E5MxmDJmmGcJ/3Nj5v/wuQgWlKpZVg3hav9FW3EqmSHdi3I3s3lRmXjq1lV
         q5mjl8DXigbPaPXwYMIjG1HA/v/M18UXzIb0bNqsYosgiyx4+OqIC5n5Yk7RcOBj2BPy
         /PO+pT1WRGfV0BcTBsAniWYZL4wKidNdT0o4HPFe+SRHjLESO4amNKNkPlP1gorkPVt/
         X4IA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAUdZwo82lTMzJJ+DHenvXrcCNVucDySWTn+btDZgWf/s0epzpF/
	53I/BnByK8FsTLDUY4+at/UCXuxL5IYnjM0cFh0jhP2mOkEQKba9sL/QqRSdl0KOccS6Vo8JQvj
	LlDtrdDUBPXZn6ZJrLaAVcBfcvY90LDNuOUsoo7FlwtoB+0Mm+TE8s/fahz1/iN4ELw==
X-Received: by 2002:a24:3988:: with SMTP id l130mr2179005ita.13.1559033600512;
        Tue, 28 May 2019 01:53:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywrhy24VNOjaK9njTKhE4n1CLCji4iBSG3GFRXHTPHwcXvzC80E/z9B2Lt8/5Z9F0OeU2W
X-Received: by 2002:a24:3988:: with SMTP id l130mr2178983ita.13.1559033599668;
        Tue, 28 May 2019 01:53:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559033599; cv=none;
        d=google.com; s=arc-20160816;
        b=JrrmYKbXJ/uBT+jrMNQNvrMtoc6LO1PKJBnXmv6ixzYWIqy8lODIXerRgt2mRW2St7
         08nR1xCdM6FgQyxAvD2SKaJusBT/zq7G5eIu9fOuNB3wzfjGTcuDNOL4lWgcc1MiUhXn
         AgEm+ZsBsQZfsT25ZeSc/dZ31Ex6nk76O5Je2s/oY+cfkAv+rt+QU+NMTFdlK+yBhloq
         qVW9PF92TOqO7oZTnUcxuVPT/kEofDnanPcV1S/3ModeiYgwqBFiXWo5fQZj0ay0yF9l
         fZ61zEnSdT91KKSGA+/qqQjVO6vvLzFQN1ima48oGSmZ8slxnfVqwhZCVi2ZJ/CO71VB
         5E3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JsTBwFuSvyYr2hB5/vQwbJjTPwMQasYFW0RoqvTjdms=;
        b=bTRCQs0SOHbYRCib6xzAXC8irG4V8flPzm+UwW+ZfHQLJQjnq8gHSU1J+sct3rCegh
         Ets4JpTT7H22rNv26I3j8o4hCjZiJQ18WwFGYHmjOr21yqVF60Xp85b4i4Apbrf2tKjJ
         rzgrmzFNrX4Xn67D3lgxO8Qn90EFa0GE3MeThq3LyVa1hD+mZIlg9rJIiVUxAq2PexsK
         MtAQjxdTMIrsJ6DxSnMEybj2SKOU6rytpvp3/YD0TRA+fJqR2WrLNYx+xW2iwo65hfk0
         836mb1cP/3sw2ILCM0XCnWk+IH89YDSi3DblY5vvbSQ1fD9IXm71Hgpu+/8uAw6PFkI6
         LNXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-164.sinamail.sina.com.cn (mail3-164.sinamail.sina.com.cn. [202.108.3.164])
        by mx.google.com with SMTP id 132si4539014iob.136.2019.05.28.01.53.19
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 01:53:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) client-ip=202.108.3.164;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CECF6F400005B21; Tue, 28 May 2019 16:53:10 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 615414400736
From: Hillf Danton <hdanton@sina.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 1/7] mm: introduce MADV_COOL
Date: Tue, 28 May 2019 16:53:01 +0800
Message-Id: <20190520035254.57579-2-minchan@kernel.org>
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190520035254.57579-2-minchan@kernel.org/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190528085301.AF1wcQ89t0nyJF5mhC5Ag-KD_VTwrRTpkUSfRSAXyQY@z>


On Mon, 20 May 2019 12:52:48 +0900 Minchan Kim wrote:
> +static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +{
> +	pte_t *orig_pte, *pte, ptent;
> +	spinlock_t *ptl;
> +	struct page *page;
> +	struct vm_area_struct *vma = walk->vma;
> +	unsigned long next;
> +
> +	next = pmd_addr_end(addr, end);
> +	if (pmd_trans_huge(*pmd)) {
> +		spinlock_t *ptl;

Seems not needed with another ptl declared above.
> +
> +		ptl = pmd_trans_huge_lock(pmd, vma);
> +		if (!ptl)
> +			return 0;
> +
> +		if (is_huge_zero_pmd(*pmd))
> +			goto huge_unlock;
> +
> +		page = pmd_page(*pmd);
> +		if (page_mapcount(page) > 1)
> +			goto huge_unlock;
> +
> +		if (next - addr != HPAGE_PMD_SIZE) {
> +			int err;

Alternately, we deactivate thp only if the address range from userspace
is sane enough, in order to avoid complex works we have to do here.
> +
> +			get_page(page);
> +			spin_unlock(ptl);
> +			lock_page(page);
> +			err = split_huge_page(page);
> +			unlock_page(page);
> +			put_page(page);
> +			if (!err)
> +				goto regular_page;
> +			return 0;
> +		}
> +
> +		pmdp_test_and_clear_young(vma, addr, pmd);
> +		deactivate_page(page);
> +huge_unlock:
> +		spin_unlock(ptl);
> +		return 0;
> +	}
> +
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +regular_page:

Take a look at pending signal?

> +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {

s/end/next/ ?
> +		ptent = *pte;
> +
> +		if (pte_none(ptent))
> +			continue;
> +
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, ptent);
> +		if (!page)
> +			continue;
> +
> +		if (page_mapcount(page) > 1)
> +			continue;
> +
> +		ptep_test_and_clear_young(vma, addr, pte);
> +		deactivate_page(page);
> +	}
> +
> +	pte_unmap_unlock(orig_pte, ptl);
> +	cond_resched();
> +
> +	return 0;
> +}
> +
> +static long madvise_cool(struct vm_area_struct *vma,
> +			unsigned long start_addr, unsigned long end_addr)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	struct mmu_gather tlb;
> +
> +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> +		return -EINVAL;

No service in case of VM_IO?
> +
> +	lru_add_drain();
> +	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> +	madvise_cool_page_range(&tlb, vma, start_addr, end_addr);
> +	tlb_finish_mmu(&tlb, start_addr, end_addr);
> +
> +	return 0;
> +}
> +
> +/*
> + * deactivate_page - deactivate a page
> + * @page: page to deactivate
> + *
> + * deactivate_page() moves @page to the inactive list if @page was on the active
> + * list and was not an unevictable page.  This is done to accelerate the reclaim
> + * of @page.
> + */
> +void deactivate_page(struct page *page)
> +{
> +	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> +		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
> +
> +		get_page(page);

A line of comment seems needed for pinning the page.

> +		if (!pagevec_add(pvec, page) || PageCompound(page))
> +			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
> +		put_cpu_var(lru_deactivate_pvecs);
> +	}
> +}
> +

--
Hillf


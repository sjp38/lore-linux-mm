Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA689C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 04:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60F2B208CB
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 04:16:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HlccYEDL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60F2B208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE83A6B0003; Thu, 20 Jun 2019 00:16:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBFA68E0002; Thu, 20 Jun 2019 00:16:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAD5D8E0001; Thu, 20 Jun 2019 00:16:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5E716B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 00:16:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u10so779460plq.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:16:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zyH9dIWlfmNUKOXTFOi3+3dsuAgnXj2LnHyE8VRoTXc=;
        b=XOB3jWTIlCOvFZOjVP9EgADMQt4AeONnI/pQwEXCzFHgLS5ATHZhlkoTYOdi7FNpdK
         VY/DH+Zoj+y+zSkMF7+WPVMofPvJVE/9mRMYUqtNlaHHpdT0ysnJHwMLWI42OI2HPyLo
         lyVDEu58SccYRbaLVxsO3TpXtJWJLaWF7bCbb2IWYYFWJQx+ReGRh5oIz4Re0asa/AMl
         O82QDCrh6NNm72LFvj0qxcAisol8jEwik+zCzVG7rZRciqIx4+aV+9t3g4FixhGGpyxi
         6Baq+imsLNVkbNNg5k0yEkI1x3WYeDxjL7W+8TWkZ74UVw2RozCN1bY9vwdAR50+IJDa
         VWvg==
X-Gm-Message-State: APjAAAV+rd4KS4YyGFrxk2zuRKft4ZhGKXSMK4p+MJxRIkfMQy73ChNH
	i6C/IayGM/BzCLDqqfc4KURrVjqhMNUHYm9Go6pwnNjcCREGJJK7MLD/dA1BZbUrgNah0fu1jvB
	NUcTZydfZSeG69D3RQh0ZisEXhv/f/7mW5+KvzHQ4BZ4jgHBHeyyyVOf17Uracz4=
X-Received: by 2002:a17:902:1e6:: with SMTP id b93mr79116190plb.295.1561004189286;
        Wed, 19 Jun 2019 21:16:29 -0700 (PDT)
X-Received: by 2002:a17:902:1e6:: with SMTP id b93mr79116143plb.295.1561004188459;
        Wed, 19 Jun 2019 21:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561004188; cv=none;
        d=google.com; s=arc-20160816;
        b=0bLMuTwAg7z0x522NyWLG/Pay5X9xAIXbOa+5wFVPfcHMepjiSBh2LVqwV2PHOelik
         x9J49ITrAbqI3ZKxy1SGf4owr/PK9QZ2LA6oSp1Fu5YeR6T2Np4f0AMIDBZj6Z2GSUjK
         /1FWQfPYQUXlhD7UdzjYNeffp3PVXimq4WLdK9qHIaqZF8XH+Ebx16sgknVoRW2BHpne
         HaIBY8mN2HxrgiYfexMrU2LtruFfS75AZGnAXhaETn4IF20NIcTkUVBPuXl4HHqli/wH
         xkMiksXgaHowVOBNnDeNoXMJF4vknzDISn7uPcwWF9CmV4YqGz7lmhCeFDozAHgVhacd
         2OLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=zyH9dIWlfmNUKOXTFOi3+3dsuAgnXj2LnHyE8VRoTXc=;
        b=czAhyBNQlyY8ippP8VBUlJZXEOxvGRJBTzmHy8KJ8l2ibZrNCXFmE97rT+1HJCuBRi
         lSNaZu3ldqpT+URV8i5khULE9BHJKA4FLbo1DE8KBKFr9DQT3JuUg7EHPzRODm9C6kvl
         bYMpXl34lMgVMTvzJNCetrEhBkryjo0Zs+WcSC07Aav0Z8WZQ0he2eav4HRVZJlSADFj
         rCp8YpYIQ2P/2SQsA9rp44gslY/nGK20qwIpB6vf81KbSqhlz5xLQ1ao952yV2Cc4l26
         32iwy696h0eU8dh0cFJ3AJDr1Fafg1JzqoDLCvtgsCL+ek4RxNf9vRMrN36A/CZYMSlp
         QoeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HlccYEDL;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor17569024pgo.57.2019.06.19.21.16.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 21:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=HlccYEDL;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zyH9dIWlfmNUKOXTFOi3+3dsuAgnXj2LnHyE8VRoTXc=;
        b=HlccYEDLCGdFzCWc2+XXxnlUmoO3pAyGNRqwlxTIzNi6/R1X8imdVc9BrUqQe7kxdf
         wjirXLQPBRskmIKpqzycg3O5Ks6K4WhYfFe2AHnmgHwkhyjQ3O1iikugt6psHm5jvF6C
         xzy8pIOiL1mVmYHXDSZ8qTeRt6Uw2pi6024sfFV2YhUQz3+IHRz2JvX/THa3K/cH1gKl
         tMCqBy1WtvaSQoh7+FtpVwYGUU88Rzuj2sj8k+PGUbqT+q3jfzKgXtyspVWDXCv69Bi6
         2AD2boCNs/jDfYHodWX5ISOCvWMQWCsLkEIV1mujAIOiJ3ET9i45v4Cv2mEu0qyjX23j
         65Kw==
X-Google-Smtp-Source: APXvYqyrXakYf1mOgEwcNtY1GbmgWRkGU/vcHWbzk94WlGzEI7BfgdBAHm4S3UHVri6Jafyu625cLQ==
X-Received: by 2002:a63:1226:: with SMTP id h38mr10879479pgl.196.1561004187871;
        Wed, 19 Jun 2019 21:16:27 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j64sm30038956pfb.126.2019.06.19.21.16.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 21:16:26 -0700 (PDT)
Date: Thu, 20 Jun 2019 13:16:20 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com, lizeb@google.com
Subject: Re: [PATCH v2 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190620041620.GB105727@google.com>
References: <20190610111252.239156-1-minchan@kernel.org>
 <20190610111252.239156-5-minchan@kernel.org>
 <20190619132450.GQ2968@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619132450.GQ2968@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 03:24:50PM +0200, Michal Hocko wrote:
> On Mon 10-06-19 20:12:51, Minchan Kim wrote:
> [...]
> > +static int madvise_pageout_pte_range(pmd_t *pmd, unsigned long addr,
> > +				unsigned long end, struct mm_walk *walk)
> 
> Again the same question about a potential code reuse...
> [...]
> > +regular_page:
> > +	tlb_change_page_size(tlb, PAGE_SIZE);
> > +	orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +	flush_tlb_batched_pending(mm);
> > +	arch_enter_lazy_mmu_mode();
> > +	for (; addr < end; pte++, addr += PAGE_SIZE) {
> > +		ptent = *pte;
> > +		if (!pte_present(ptent))
> > +			continue;
> > +
> > +		page = vm_normal_page(vma, addr, ptent);
> > +		if (!page)
> > +			continue;
> > +
> > +		if (isolate_lru_page(page))
> > +			continue;
> > +
> > +		isolated++;
> > +		if (pte_young(ptent)) {
> > +			ptent = ptep_get_and_clear_full(mm, addr, pte,
> > +							tlb->fullmm);
> > +			ptent = pte_mkold(ptent);
> > +			set_pte_at(mm, addr, pte, ptent);
> > +			tlb_remove_tlb_entry(tlb, pte, addr);
> > +		}
> > +		ClearPageReferenced(page);
> > +		test_and_clear_page_young(page);
> > +		list_add(&page->lru, &page_list);
> > +		if (isolated >= SWAP_CLUSTER_MAX) {
> 
> Why do we need SWAP_CLUSTER_MAX batching? Especially when we need ...
> [...]

It aims for preventing early OOM kill since we isolate too many LRU
pages concurrently.

> 
> > +unsigned long reclaim_pages(struct list_head *page_list)
> > +{
> > +	int nid = -1;
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
> > +		if (nid == -1) {
> > +			nid = page_to_nid(page);
> > +			INIT_LIST_HEAD(&node_page_list);
> > +		}
> > +
> > +		if (nid == page_to_nid(page)) {
> > +			list_move(&page->lru, &node_page_list);
> > +			continue;
> > +		}
> > +
> > +		nr_reclaimed += shrink_page_list(&node_page_list,
> > +						NODE_DATA(nid),
> > +						&sc, 0,
> > +						&dummy_stat, false);
> 
> per-node batching in fact. Other than that nothing really jumped at me.
> Except for the shared page cache side channel timing aspect not being
> considered AFAICS. To be more specific. Pushing out a shared page cache
> is possible even now but this interface gives a much easier tool to
> evict shared state and perform all sorts of timing attacks. Unless I am
> missing something we should be doing something similar to mincore and
> ignore shared pages without a writeable access or at least document why
> we do not care.

I'm not sure IIUC side channel attach. As you mentioned, without this syscall,
1. they already can do that simply by memory hogging
2. If we need fix MADV_PAGEOUT, that means we need to fix MADV_DONTNEED, too?


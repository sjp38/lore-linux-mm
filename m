Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07A4FC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:15:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 980EB208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:15:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 980EB208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27FD36B027A; Tue, 28 May 2019 08:15:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2093F6B027E; Tue, 28 May 2019 08:15:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D0276B027F; Tue, 28 May 2019 08:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9B0B6B027A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:15:38 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so5255793iob.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:15:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=lmyNk6dxmfIG2OYP5boL0lkj552oevOEYba+hKb6yaM=;
        b=kwNxUyk1Nu8Y3fqBJhM0nc47r8jSJy4jTM9RJuzRo/wCncNUt4ioOHCVgtagdW5D/U
         kobhXkYuDt3Wn+ga/16nvu1HoXBu3ncmAnXIMo+3TlQpqhsm0d6cn110OHUiq50iL4iU
         vEO94bLVhkL4EPjNedPLGblJyXoHRz5rhThAaDXziut8RpY6VKnZ2F7jnoDwZcE8xADc
         qoF4NQO9mLl1Jw6JeqFtHKaZ3SvqwmynG7rvtb2PFeF70XJUaj6GuWEmvaUfZpKBUhpD
         RyPl3astkz0qRQIKY2HCAFMjzPkVGhenUnQsMG0Ppu6718lQeyo5CjsooqEdJQpE6K+s
         Tosw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVC9INsU9DzkEefv+dogYQ7JlV8WbvAokZ8+z8CaM86JS0kNmq/
	mJ8EI+vhJUrW1nwXM5rJIIhyPAnGvH+AAUpnS3MmnIyUnL2+W7ovtg1EnM4zTuU8SZVccCYSPgf
	YV6VH4yMWn+mH3NUZBvFRDpUZL8iSNXaYvoYyGqAJFp5qtOYf4zoYwIJLf9khzf3hUg==
X-Received: by 2002:a5d:994d:: with SMTP id v13mr19527664ios.77.1559045738575;
        Tue, 28 May 2019 05:15:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2t0k7DM38WXSwfbl0LLWoyPQEM5Sy/kXj9IQ8FaOeyEx3Q436uxbQsGS9RhiYYSJdXDc9
X-Received: by 2002:a5d:994d:: with SMTP id v13mr19527599ios.77.1559045737447;
        Tue, 28 May 2019 05:15:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045737; cv=none;
        d=google.com; s=arc-20160816;
        b=vuUMEZs6DZLkhqK9dqEekGvjzY/jH/GlfdTIDi6e/JxjI6DjzGzNlIVX0e2vO4U7AP
         X2LVaQEEZffIH/Z3rLcRsDKSooMtdW7HGDenuq1grIZ2TGujGSX3SpzNV/2XyvDD6CHj
         t84f6HU42l9b8M9ghtQbwzsuZc6GnOIcy1aZH4cMpnVDGQb4hlSiCLN5BbdaXtM8i0US
         tsuVug0Q/I4s/jgKHH+B7afcDKf06QVHCW18n2Kfk1sohyM/3DFyo4SNujR/hCqMoG16
         qyE1ZBqlEYD0nChGyRXw/i8lTkX5TTu0g6UlpOHWKe+K9DkCQhcUg64cQdP86lH+teX0
         caiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=lmyNk6dxmfIG2OYP5boL0lkj552oevOEYba+hKb6yaM=;
        b=mhpNJcPJVemKX1DXqeita3nz4cAV9wpk00L63KxCfaMOoHIVmrLqbjgiklhQRCZkyM
         r1Ybkn2W1+9Xst4JBPitC0EJYlqUsZ2SD4nJG2ej5Db1VjqeqZExPMYGSjbMFvtuZu1V
         p3LCyKvWWtoHAwQRFjPUoLu/0fnIN9MIrH6PPQ/7uxSFEoirEbnoiUrfHmEPL0yJKom4
         GS54/b7JKq4lTsVoyR+ux7Gj5f2MLjRaQ7np8uplngCBeZVGL/DgB9W8sY+4qXh1CIna
         a2DXLHfRN6qOY7NWK6fW69n1IC+BC80VesYdb57WULg5yte9T65vzBkifqd0H7FkARPU
         yoyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-212.sinamail.sina.com.cn (mail7-212.sinamail.sina.com.cn. [202.108.7.212])
        by mx.google.com with SMTP id o15si9814463jam.15.2019.05.28.05.15.36
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 05:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) client-ip=202.108.7.212;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.212 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CED266200006C96; Tue, 28 May 2019 20:15:32 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 532432396764
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
Date: Tue, 28 May 2019 20:15:23 +0800
Message-Id: <20190528121523.8764-1-hdanton@sina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 28 May 2019 18:58:15 +0800 Minchan Kim wrote:
> On Tue, May 28, 2019 at 04:53:01PM +0800, Hillf Danton wrote:
> >
> > On Mon, 20 May 2019 12:52:48 +0900 Minchan Kim wrote:
> > > +static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
> > > +				unsigned long end, struct mm_walk *walk)
> > > +{
> > > +	pte_t *orig_pte, *pte, ptent;
> > > +	spinlock_t *ptl;
> > > +	struct page *page;
> > > +	struct vm_area_struct *vma = walk->vma;
> > > +	unsigned long next;
> > > +
> > > +	next = pmd_addr_end(addr, end);
> > > +	if (pmd_trans_huge(*pmd)) {
> > > +		spinlock_t *ptl;
> >
> > Seems not needed with another ptl declared above.
>
> Will remove it.
>
> > > +
> > > +		ptl = pmd_trans_huge_lock(pmd, vma);
> > > +		if (!ptl)
> > > +			return 0;
> > > +
> > > +		if (is_huge_zero_pmd(*pmd))
> > > +			goto huge_unlock;
> > > +
> > > +		page = pmd_page(*pmd);
> > > +		if (page_mapcount(page) > 1)
> > > +			goto huge_unlock;
> > > +
> > > +		if (next - addr != HPAGE_PMD_SIZE) {
> > > +			int err;
> >
> > Alternately, we deactivate thp only if the address range from userspace
> > is sane enough, in order to avoid complex works we have to do here.
>
> Not sure it's a good idea. That's the way we have done in MADV_FREE
> so want to be consistent.
>
Fair.

> > > +
> > > +			get_page(page);
> > > +			spin_unlock(ptl);
> > > +			lock_page(page);
> > > +			err = split_huge_page(page);
> > > +			unlock_page(page);
> > > +			put_page(page);
> > > +			if (!err)
> > > +				goto regular_page;
> > > +			return 0;
> > > +		}
> > > +
> > > +		pmdp_test_and_clear_young(vma, addr, pmd);
> > > +		deactivate_page(page);
> > > +huge_unlock:
> > > +		spin_unlock(ptl);
> > > +		return 0;
> > > +	}
> > > +
> > > +	if (pmd_trans_unstable(pmd))
> > > +		return 0;
> > > +
> > > +regular_page:
> >
> > Take a look at pending signal?
>
> Do you have any reason to see pending signal here? I want to know what's
> your requirement so that what's the better place to handle it.
>
We could bail out without work done IMO if there is a fatal siganl pending.
And we can do that, if it makes sense to you, before the hard work.

> >
> > > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> >
> > s/end/next/ ?
>
> Why do you think it should be next?
>
Simply based on the following line, and afraid that next != end
	> > > +	next = pmd_addr_end(addr, end);

> > > +		ptent = *pte;
> > > +
> > > +		if (pte_none(ptent))
> > > +			continue;
> > > +
> > > +		if (!pte_present(ptent))
> > > +			continue;
> > > +
> > > +		page = vm_normal_page(vma, addr, ptent);
> > > +		if (!page)
> > > +			continue;
> > > +
> > > +		if (page_mapcount(page) > 1)
> > > +			continue;
> > > +
> > > +		ptep_test_and_clear_young(vma, addr, pte);
> > > +		deactivate_page(page);
> > > +	}
> > > +
> > > +	pte_unmap_unlock(orig_pte, ptl);
> > > +	cond_resched();
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static long madvise_cool(struct vm_area_struct *vma,
> > > +			unsigned long start_addr, unsigned long end_addr)
> > > +{
> > > +	struct mm_struct *mm = vma->vm_mm;
> > > +	struct mmu_gather tlb;
> > > +
> > > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > > +		return -EINVAL;
> >
> > No service in case of VM_IO?
>
> I don't know VM_IO would have regular LRU pages but just follow normal
> convention for DONTNEED and FREE.
> Do you have anything in your mind?
>
I want to skip a mapping set up for DMA.

BR
Hillf


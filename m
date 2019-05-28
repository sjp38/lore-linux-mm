Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6987CC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:38:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 152032075C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:38:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 152032075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876586B0276; Tue, 28 May 2019 11:38:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 827956B0279; Tue, 28 May 2019 11:38:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EE7A6B027A; Tue, 28 May 2019 11:38:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42F626B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 11:38:33 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id y14so6486966oia.9
        for <linux-mm@kvack.org>; Tue, 28 May 2019 08:38:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=QqHi5rnCnje298s5JTOgIMBpgHjAjm+mGWSK41+WGKI=;
        b=Pf5iYrErix/ozcDql4wpJjShdp7ZZGy8mXfxcYYIPZV0Pl29LF+6UnmboTL4SpTw75
         CFxAcsEPhw7qMZCtfQe2HGuSILDeX165ACFTXIQEmi1LAbZZmJ9cVmrQcOsSsAjxr6Pd
         as4gt9/EAsAS4XUfGFuhZR8QpfcHWiDS9cuFrUQppD3H1how5DnBvnrOgKNdwBzL1A6o
         qIbhngBJ+EGauSw04cNdy7pb06c8aiOoZ6IU3d/p4A8/lrRKcO8KWK9/fDXxROQWjtQL
         UjsVbmwtOLBMYOyO/bLkSZ6dGo8LAn6yOnmtnQoQOjWesqSOpnSqOIdBPL/veZ3hkjmt
         vjwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAXhrEBP3DWXEMwMPJI7QbPfPZx/hktu006PS9HdzcGeQtFWyc6U
	sl/sWNsTuieBYy8QAB0SWeqPgZBH7tJsFwJ4UbC7Q0q6gFOFj/oAoVgp3G5K8mkq9fd+DBZy2GB
	ctcDQbf3mCoNK7NRgU7VOuR6MHN+oYi9tdr+tTfo3RGL0/ijxrqUO19i6+PAAcLcyBA==
X-Received: by 2002:a9d:6b0d:: with SMTP id g13mr40038899otp.91.1559057912982;
        Tue, 28 May 2019 08:38:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUX7yuRNmkL+u97+JwznEJJt48Pc2OYRbrEF05R06Um9UEFdebYZIQCpU4EoDGeJ6k6Xov
X-Received: by 2002:a9d:6b0d:: with SMTP id g13mr40038824otp.91.1559057911848;
        Tue, 28 May 2019 08:38:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559057911; cv=none;
        d=google.com; s=arc-20160816;
        b=tSUkp4kQdeFi/aFfxGAbMEgNGb2SDs9fiEZeELhiiG3hfH+lnuJScnur16Krv0jTm3
         ezl2Bf+gx94fiMrCt17mNqDMTWIc+QrZ6DL64Kr70Xigz8K+/3WRAqXdQAihc/tvdGpm
         pxzs3oEkJzaKNen9AxOC18dnAk8xKxWHcC3krG6+31BBuBMkTrQ9tkuBYMDtZA2rvm+1
         JUobZR5HH5TfszFxIfdZwZFnXSyfHcjk76gAHxCbUCs2xX+QZ8esQOsu/ZxlbhzKgPkF
         8FBzVf7ohIoHrVU/hUyy5tfQ6Xukphm2X6CtlaN2rtwaTPR2/81I0fHgt7P6gR9byqLL
         4d6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=QqHi5rnCnje298s5JTOgIMBpgHjAjm+mGWSK41+WGKI=;
        b=JnhKZDXipEr9pn5EErE2GaBRmVBiuFw8mkzuD/em7uns4hLqUA/RpnAvJMH61v3pZa
         b0c1egA6znAdfKtgDsJeeJjPWNP4s3tgZr/j+kpj3gidrdozafYh93cFdaytzSh5kp37
         UMahyPsPx2C0BlWHdtLqdbQfilUWr9FT2v6kzb+S9C/l105X8MWS3IbsDpC+Iq0bedlT
         yFdEB3LzVlEdwy9e88oaLrMLGGg/X+WjzPX7Yh+EiLo09ZK5vv7JRkM4U501ppXtnPX5
         kMrcBrRskJmGbUkD2BAIhdRZc5oEeLjpfuC6ZjjLODuAN3YP/X4ZH4ep4o7rG8haPSFS
         IfyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-162.sinamail.sina.com.cn (mail3-162.sinamail.sina.com.cn. [202.108.3.162])
        by mx.google.com with SMTP id n28si9105944otj.17.2019.05.28.08.38.30
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 08:38:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) client-ip=202.108.3.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.162 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CED55EB00004A05; Tue, 28 May 2019 23:38:22 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 193347399538
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
Date: Tue, 28 May 2019 23:38:11 +0800
Message-Id: <20190528153811.7684-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: [RFC 1/7] mm: introduce MADV_COOL
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 28 May 2019 20:39:36 +0800 Minchan Kim wrote:
> On Tue, May 28, 2019 at 08:15:23PM +0800, Hillf Danton wrote:
> < snip >
> > > > > +	orig_pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > > > > +	for (pte = orig_pte; addr < end; pte++, addr += PAGE_SIZE) {
> > > >
> > > > s/end/next/ ?
> > >
> > > Why do you think it should be next?
> > >
> > Simply based on the following line, and afraid that next != end
> > 	> > > +	next = pmd_addr_end(addr, end);
> 
> pmd_addr_end will return smaller address so end is more proper.
> 
Fair.

> > > > > +static long madvise_cool(struct vm_area_struct *vma,
> > > > > +			unsigned long start_addr, unsigned long end_addr)
> > > > > +{
> > > > > +	struct mm_struct *mm = vma->vm_mm;
> > > > > +	struct mmu_gather tlb;
> > > > > +
> > > > > +	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> > > > > +		return -EINVAL;
> > > >
> > > > No service in case of VM_IO?
> > >
> > > I don't know VM_IO would have regular LRU pages but just follow normal
> > > convention for DONTNEED and FREE.
> > > Do you have anything in your mind?
> > >
> > I want to skip a mapping set up for DMA.
> 
> What you meant is those pages in VM_IO vma are not in LRU list?

What I concern is the case that there are IO pages on lru list.
> Or
> pages in the vma are always pinned so no worth to deactivate or reclaim?
> 
I will not be nervous or paranoid if they are pinned.

In short, I prefer to skip IO mapping since any kind of address range
can be expected from userspace, and it may probably cover an IO mapping.
And things can get out of control, if we reclaim some IO pages while
underlying device is trying to fill data into any of them, for instance.

BR
Hillf


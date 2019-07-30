Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14176C41514
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE19420C01
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:15:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE19420C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 784D38E0006; Tue, 30 Jul 2019 10:15:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70C9E8E0001; Tue, 30 Jul 2019 10:15:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4128E0006; Tue, 30 Jul 2019 10:15:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6818E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:15:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y15so40454284edu.19
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:15:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VzLHdt78SBlKwFKmTgViLMBXCBNHkaefwI/WP1KIZFM=;
        b=TZQJAITb4ulLf2SpXsmK5wnNypYA8rAoFVv7WcBBxWcGPbEu0DwRaOwVCL3qCF/20u
         CXyTfm9vRnOMbGKdcUuoVXEQQ4UFpNrd7oHw2ROEu3Q9HA0qY9GxpY5hj/pf/esDh15W
         D2L9XDQOy9tQnxwa/OgrnbRLfz3Uaw/XD7CUBDzvc8oPoNPDcnvUNzfkEmh/b91EkTNA
         xyIw+eWejAHliwdKdiHcARItApl0xLej3q2OSpdkxSffhMEC3ZDjBvmXtGxyrWki0EQp
         vk7rd/K821y8498cZ7xWRb8nm1WavNV16uXn+L9kOwu3yH1KUEre6ez+AUN2x3OTEqE7
         /5sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXWlGbGA3uLfqfdV8YG2kTfimrDWBZ0soQbgblkKvgpqQKEle0s
	3yApeSBlpBckcBpWMoAD6OGU0R87oYko3xfMvKNiib71QcblobKMLdsLZjjBgkmEgXobauXb3hn
	bYt2Vvwf+ABlSldj266ht0zqd2OAcbqz7VB4pVBxeFQrSDBYjc4iFstW08lg21kWUwg==
X-Received: by 2002:a50:ad45:: with SMTP id z5mr100644309edc.21.1564496099305;
        Tue, 30 Jul 2019 07:14:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhUTLIwAwjTy7D4zRNtY3qn+Fa1A9tPbSIBSD7CMuVu92DJF3RNly7Qj9mdZC4ioB1thWj
X-Received: by 2002:a50:ad45:: with SMTP id z5mr100644252edc.21.1564496098596;
        Tue, 30 Jul 2019 07:14:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564496098; cv=none;
        d=google.com; s=arc-20160816;
        b=QWARUZ8CTCZpblH9UFpfgr0UKt5NFdD3RWrvPQ8NWzym+2wq8pGAb5uujS0XKV7fv8
         rLIBnSWYxphfin49wgfoJTxeYR2dPWpm3H8ARyVAoXqR2TVPVkL3QH5eCLP2GptyN48+
         usuw34GsEWfT8+x7+7pp4C/2BoH5MIYKYmUOWtvmxFqQ6eE7Jnp16Y9bsu2wBFLrpnBQ
         ir97uTkGmO6mqB0E6wvqkRHOom/39KFDOc2q1YkbOrI6eTrLaH+34Rn0KhBWSCJEIetC
         rZAaRrB0EV2R+/H7YXHaf8HPQT8bDdwaAdR4IOnuILZHz41hPySZAda95IJ68uCRBGfO
         lf0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VzLHdt78SBlKwFKmTgViLMBXCBNHkaefwI/WP1KIZFM=;
        b=nnddvuF1uLow55b2qrydLpudTlyFo/7jBp+p/pY9sC7MVkSReopzedXrWjj5Z3upG+
         HK+Y8vfz5C5qri1ZK5w2gFkvCAx9ku4scX3sESBPj4mqly4aas99oB9PvFdddMMOZzt0
         prcoy/niCyjjFlat57arp+VqZoKGrnA3vip8IXBeKRgw2djpmIU7O9RgXIAPrKpBrN3M
         LpueSxnHELq76RdCxF76SjSE3AgsAwd0+bzT0I0o19WvNNrnbds/nIWDWmbOgCSGwd0f
         iarIbiHpq9YE+k6h3zhDBrB0CIpG1rudzXZzyQG2PGYk7F0KlQ9tyo2G5rJ+NJv6DlJL
         dLxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mj3si16446416ejb.17.2019.07.30.07.14.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 07:14:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B182FADDC;
	Tue, 30 Jul 2019 14:14:57 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 0AE211E440D; Tue, 30 Jul 2019 16:14:57 +0200 (CEST)
Date: Tue, 30 Jul 2019 16:14:57 +0200
From: Jan Kara <jack@suse.cz>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>,
	linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm/filemap: don't initiate writeback if mapping has
 no dirty pages
Message-ID: <20190730141457.GE28829@quack2.suse.cz>
References: <156378816804.1087.8607636317907921438.stgit@buzz>
 <20190722175230.d357d52c3e86dc87efbd4243@linux-foundation.org>
 <bdc6c53d-a7bb-dcc4-20ba-6c7fa5c57dbd@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bdc6c53d-a7bb-dcc4-20ba-6c7fa5c57dbd@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-07-19 11:16:51, Konstantin Khlebnikov wrote:
> On 23.07.2019 3:52, Andrew Morton wrote:
> > 
> > (cc linux-fsdevel and Jan)

Thanks for CC Andrew.

> > On Mon, 22 Jul 2019 12:36:08 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
> > 
> > > Functions like filemap_write_and_wait_range() should do nothing if inode
> > > has no dirty pages or pages currently under writeback. But they anyway
> > > construct struct writeback_control and this does some atomic operations
> > > if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
> > > updates state of writeback ownership, on slow path might be more work.
> > > Current this path is safely avoided only when inode mapping has no pages.
> > > 
> > > For example generic_file_read_iter() calls filemap_write_and_wait_range()
> > > at each O_DIRECT read - pretty hot path.

Yes, but in common case mapping_needs_writeback() is false for files you do
direct IO to (exactly the case with no pages in the mapping). So you
shouldn't see the overhead at all. So which case you really care about?

> > > This patch skips starting new writeback if mapping has no dirty tags set.
> > > If writeback is already in progress filemap_write_and_wait_range() will
> > > wait for it.
> > > 
> > > ...
> > > 
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
> > >   		.range_end = end,
> > >   	};
> > > -	if (!mapping_cap_writeback_dirty(mapping))
> > > +	if (!mapping_cap_writeback_dirty(mapping) ||
> > > +	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
> > >   		return 0;
> > >   	wbc_attach_fdatawrite_inode(&wbc, mapping->host);
> > 
> > How does this play with tagged_writepages?  We assume that no tagging
> > has been performed by any __filemap_fdatawrite_range() caller?
> > 
> 
> Checking also PAGECACHE_TAG_TOWRITE is cheap but seems redundant.
> 
> To-write tags are supposed to be a subset of dirty tags:
> to-write is set only when dirty is set and cleared after starting writeback.
> 
> Special case set_page_writeback_keepwrite() which does not clear to-write
> should be for dirty page thus dirty tag is not going to be cleared either.
> Ext4 calls it after redirty_page_for_writepage()
> XFS even without clear_page_dirty_for_io()
> 
> Anyway to-write tag without dirty tag or at clear page is confusing.

Yeah, TOWRITE tag is intended to be internal to writepages logic so your
patch is fine in that regard. Overall the patch looks good to me so I'm
just wondering a bit about the motivation...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 227B1C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:24:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C92FA21874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:24:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C92FA21874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DFCC6B0003; Thu,  8 Aug 2019 06:24:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 290616B0006; Thu,  8 Aug 2019 06:24:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A7606B0007; Thu,  8 Aug 2019 06:24:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCDC36B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 06:24:56 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l24so44976807wrb.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:24:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gqMcrLj1gVdJ2hsnWbaulPrTKyA0AE1cZMK6/01FJPg=;
        b=rJnUCcCRa1ylnzxqjeiG5QUgMe3EoiIvR67ywJ1eIPKiqFMNFQ5QUhGmBAcT0YJNhV
         H9VnExAU0pT1GYMhZ6NAmNtNBLf+Ew2ltHMS0taHQGBIdi3X38eBF5UhG2Xbc9y7OmXx
         ne2WSA/AdqYDdWsNtXOZ1PqHQDuScrQLMdJ6fkwB2T+rFOUVTxafSZfUBW44EZ5q0eye
         f/ssbuucR2lvXqlOtf7TLWK4m2NxkVWzTHvAjs0mjKqBUmnOpWMmNpNukjlGNaz0+oQh
         uy6+yLX14rkT4TOZsUuDYn+Rz68Z/uWnwOL+pDOh50to8ApiQZBlvF2mzsHpNNnN7/ko
         GB1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXIz2xp9ViDS8QQiom/nKwx+IufhUf4mlxyFJXB3Fhu653nwnAc
	Ubk/xvPiVmNIahv5tAmwcmrdQ6eb4TyEDti/8SR770blJ6vzjSVXShU+LQDo4AZBZgarBI1MtWD
	78nWwOf5HdBA6ilG6pu9iWa/dWj13gejtIpb9KRSpHesVOlMKjJxtxH6mRL3124b0FQ==
X-Received: by 2002:a5d:5647:: with SMTP id j7mr15965571wrw.191.1565259896393;
        Thu, 08 Aug 2019 03:24:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbjfrtja9QgxKaxLbvKmLprf3b2fKbit8FdY96CdLmuu+ykp6j+yQJOM7D3LNl5VuK9bjH
X-Received: by 2002:a5d:5647:: with SMTP id j7mr15965451wrw.191.1565259894991;
        Thu, 08 Aug 2019 03:24:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565259894; cv=none;
        d=google.com; s=arc-20160816;
        b=gTndvu0xS8PolMIRc29+f4hO7DoHgs/RcfvndCZSUuzdqPr/Cx2f0eXQSqMnHleW2w
         O7SXYC1wzBM32+79yCovCJxrAsiWUi6pFYDQ48EJLiiCd64T+2AMDb5yoBe/W8d47pGe
         5fw33la3hSEBQDvuFmMLNt28GU8hgR4OENh2a0babkNXWTijFMCbCpGH5r9Xpzn9XNFG
         GmYwUnQqanjzVl4VTH/w+XmPQ3zSBGayefrt/8EQapHFJ7xVBPICNVAH/DlPlHZv6XG+
         k0HczpcqE7Lbwwa2rpUbfL8AnETA4FT8yWTrzTf+mvgDdZ6qjivK1cE+YvtGdlZv5kR5
         G6sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gqMcrLj1gVdJ2hsnWbaulPrTKyA0AE1cZMK6/01FJPg=;
        b=Z/VAWhnWMCX+1V27HSnbHEGQjpqODyXaFNXj3uQdvIBRflfC4Zz/TtoMFigTUrS5ue
         XmVoJ22y0JetzBj9UryJ1C5V0vRc9oFTyhZSJ0qPFtNBWwwrc5kZzRGASOKVKFTo2Gdu
         EyfWqo809JNAm4tbH9w4f97xy9uLCzdMFsI5u0cFHpnqdcU8+NOeg4n/ZkN1VcEub5rr
         lxx560lCEU70KHFmmyv3neMlsd1xn4NWKNgEN1mGZFpAqfu+LCU9uYhAXwZbeVGHVpwy
         5jh8j14BpWdv/HiAYnQ+GSp7eyjneNoywEuxVa/Bd1wW41mTRwd3S9mfSYOH634p2M9C
         gqJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m9si1344440wmg.153.2019.08.08.03.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 03:24:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3F93F227A81; Thu,  8 Aug 2019 12:24:52 +0200 (CEST)
Date: Thu, 8 Aug 2019 12:24:52 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 hmm 01/11] mm/mmu_notifiers: hoist
 do_mmu_notifier_register down_write to the caller
Message-ID: <20190808102452.GA648@lst.de>
References: <20190806231548.25242-1-jgg@ziepe.ca> <20190806231548.25242-2-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-2-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:15:38PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This simplifies the code to not have so many one line functions and extra
> logic. __mmu_notifier_register() simply becomes the entry point to
> register the notifier, and the other one calls it under lock.
> 
> Also add a lockdep_assert to check that the callers are holding the lock
> as expected.
> 
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>


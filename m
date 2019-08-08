Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB422C32754
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:26:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AFD121874
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:26:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AFD121874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32C1B6B0008; Thu,  8 Aug 2019 06:26:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B5936B000A; Thu,  8 Aug 2019 06:26:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17DF66B000C; Thu,  8 Aug 2019 06:26:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD27A6B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 06:26:55 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w11so44872366wrl.7
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:26:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kW8zuazzNE9wLabfrrhykpKeWzoQ/jJUoB11n83RL58=;
        b=mvIO0XhaVbF2dhCUpfORlHOogeI2vHB4xDWfpaRHPd9Hudbs22X93i8oN4z4BnvuAt
         AA2gu85rwPrZMd0DOfL2sMLyD9nMM8i9CU3eI0A70vcpj/GgA9bUjpsbU0dS+o3tDwEO
         Zmhx1+9I/9sVwc8AQmpMJ9mS3xl7zjL9tTtAc66ZGyVTdQ2PdH2bOZuu965KRkVca3yu
         tibS6HRatJ93pR5jP3ImUE05s61HSro3cL0cGrTAXGGQ5jvhYyWLTrUHUVtmIcUvL8RQ
         kQgetEL/DW3Bgin2NfMJp5T2oiwfK3FcDVllTrzR1zQbUlv5UK6RDbozdpYSK78EMuuY
         BK6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUrcStyBzL8IVrIY9EpHzPXnLTK5dqBrOtCXt19uxUEMbR7sOeo
	S0+e0vq+ITW76Vju8LOedpjsIV/5wPLTNn8M0apTqDNDV3MqT0yF90VvhQCSLBbO4d4u9xRHW//
	Rc+UfRvrIAC4i3F18NbItEHk5sUFCFRA+hlwjrEsAR3l8OY14M7uW48dkgAOI6ah/sA==
X-Received: by 2002:a1c:4d6:: with SMTP id 205mr3291926wme.148.1565260015361;
        Thu, 08 Aug 2019 03:26:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlaUi+Lxy5ps76rR8ZZO04T+9uYm54xNgwv3V3CdjB/0d5wbLlOe7fnwOOV3Pu0REwoZhJ
X-Received: by 2002:a1c:4d6:: with SMTP id 205mr3291842wme.148.1565260014526;
        Thu, 08 Aug 2019 03:26:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565260014; cv=none;
        d=google.com; s=arc-20160816;
        b=LPju8reBMAncRNx9zXn3iJtvADrGBSL+YFCXQ9M/JRnGPQIOSXHs+FsSvQoCbW3sa4
         W1WOKxIzeeUyRdsFTPASbpqvJ+i1692mEx6TbCReIV3OuQxUNiOnMj0hRcr3/JHT63Ye
         MRjtz2CgfpTEz8UiH6vunaBXAosAKcsMUFBpBHzxx8PqmmaWKtkYgjCVRpgGW+o+oqrx
         KwW3lAluC7Pj7H9BAvXqea5fhsUWFZ+cHlBRN4/7avrkwv0RCThaenA7qfNUgIRsM4Q/
         a6951NdEN4j1/wqBYzAR7TpG6IAANERHsDhenHuj9eStWgF1kFK6SBIa+P49DZkaUFOy
         U2oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kW8zuazzNE9wLabfrrhykpKeWzoQ/jJUoB11n83RL58=;
        b=pmR/KDatzXAui0xvoMGnRElOopX3dKiUehZfSW1OfHNDymxgGYzlPI2xphLaLVJaDo
         nQIOQjernxZxj3A1BAWcwqvicwtilgTWdqlj4YnThqrqSbYM5Fcp5SHgo6B3NEOGgtLm
         GjgcZFBVz+Ws3yXXgKhztiwRbdcZCkeccjnt6tb+V8zhdnO0CQw6r4uVz8CsffegYIPm
         yHpa7NYooFsoNmv7yR4pAl37u/TM3Ee3ccbbzXn9ffPtir30399kTibUri6fBIaZgOSb
         2GhZCO5vds/aPtiILjKz4Azy8KpHuHt6qCj1X0MvuU7bkeXKQ1/7669xy0jlAGcise6f
         MKVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d198si1360709wmd.56.2019.08.08.03.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 03:26:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8BF8768B02; Thu,  8 Aug 2019 12:26:52 +0200 (CEST)
Date: Thu, 8 Aug 2019 12:26:52 +0200
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
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v3 hmm 02/11] mm/mmu_notifiers: do not speculatively
 allocate a mmu_notifier_mm
Message-ID: <20190808102652.GC648@lst.de>
References: <20190806231548.25242-1-jgg@ziepe.ca> <20190806231548.25242-3-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-3-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:15:39PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> A prior commit e0f3c3f78da2 ("mm/mmu_notifier: init notifier if necessary")
> made an attempt at doing this, but had to be reverted as calling
> the GFP_KERNEL allocator under the i_mmap_mutex causes deadlock, see
> commit 35cfa2b0b491 ("mm/mmu_notifier: allocate mmu_notifier in advance").
> 
> However, we can avoid that problem by doing the allocation only under
> the mmap_sem, which is already happening.
> 
> Since all writers to mm->mmu_notifier_mm hold the write side of the
> mmap_sem reading it under that sem is deterministic and we can use that to
> decide if the allocation path is required, without speculation.
> 
> The actual update to mmu_notifier_mm must still be done under the
> mm_take_all_locks() to ensure read-side coherency.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>


Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739D2C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:53:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34A8721655
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 19:53:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Axfhikvj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34A8721655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE53E6B0003; Wed, 21 Aug 2019 15:53:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C95856B02A2; Wed, 21 Aug 2019 15:53:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAB246B02A4; Wed, 21 Aug 2019 15:53:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 93A276B0003
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:53:04 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 5A33945AE
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:53:04 +0000 (UTC)
X-FDA: 75847483488.23.tail98_1ac5048ef8805
X-HE-Tag: tail98_1ac5048ef8805
X-Filterd-Recvd-Size: 4605
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 19:53:03 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id u190so2976247qkh.5
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 12:53:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Avf248fSzuypFcso7Kkr0yA+lcmduhMaWHH94TkjpAI=;
        b=AxfhikvjRrOipQcntJRqjdr/eKvR8BEra5qlDG10hvhnCuoV2Y1rax7uZg5mfRHTHC
         uPaWNuH6Em8WzNOLx9kTZ3NE540jiIjPDyL116dF2ihKw7XrA7R8XahBlEtlmkpTrEca
         iiMP7POS3K8y6Kjq4ZtTUy8g4uMiJ8gVVTdfnXrqGDdfUfCnK8ClM5wD8SM+V4khKCtG
         GxBMkz9dMuyiKJVS7YQukqCbImb4gRl3aNgGS/xQvglUUbXbj0EYMXZXq6GP+7adG5Jr
         vBXarNpeiZyR7KKPZZeJfz7rr0BkCL3tTmpq3tB8OjRr7Lbf17hUatbpQDkomugG4wri
         qr5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=Avf248fSzuypFcso7Kkr0yA+lcmduhMaWHH94TkjpAI=;
        b=iIBEmPushpEcWaKPGAJ0X3GFLP7ZO8YI1wu7aMRk8v+X71NI22jNOMTK7NLCxrAySD
         5YaxwBui2yzssAuImNHMRCakDHRtKAEVbRs7iv8Bv6WLsW3koa7Xlmjck3gJVR1TQfLv
         vTNSzUHiOUzuMNqPh2KMAW4+kqABxKuUSHCgyOsyWpbOfVCez0XbGM8RGquOt+PEpYoo
         P16J8hGySxxm42KElDK9cQl5YTc1CcNJ6D0B3jJ+daQgjRob/4LpIeC/q2CenhTAUKHr
         5/lsWRVV8Q/ZGRcqYtFqSVec/3a3EsUpxntx1bOY3zcDUhSarrROMzCAQg9Bj1WpTTYL
         N/YA==
X-Gm-Message-State: APjAAAXtVbyDyt1fzPSgrInvY0hNcOFhrHufpIFhdo2fDO9n2Ywi5FYd
	lz7EC4N8/0R4Rdc1ioUf+ueBha2B0hw=
X-Google-Smtp-Source: APXvYqwPksLN/jmRrXTfKl1JB/9WM5tJ8kTKLiTdMf+ZNHYSP0hbNDBV4ZLxlKKKGF2mGcl3vHw8pg==
X-Received: by 2002:a37:9701:: with SMTP id z1mr17576531qkd.66.1566417183189;
        Wed, 21 Aug 2019 12:53:03 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id b202sm10311656qkg.83.2019.08.21.12.53.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Aug 2019 12:53:02 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i0WfG-0005oO-5E; Wed, 21 Aug 2019 16:53:02 -0300
Date: Wed, 21 Aug 2019 16:53:02 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v3 hmm 00/11] Add mmu_notifier_get/put for managing mmu
 notifier registrations
Message-ID: <20190821195302.GA22164@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-1-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000173, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:15:37PM -0300, Jason Gunthorpe wrote:
 
> This series is already entangled with patches in the hmm & RDMA tree and
> will require some git topic branches for the RDMA ODP stuff. I intend for
> it to go through the hmm tree.

The RDMA related patches have been applied to the RDMA tree on a
shared topic branch, so I've merged that into hmm.git and applied the
last patches from this series on top:

>   RDMA/odp: use mmu_notifier_get/put for 'struct ib_ucontext_per_mm'
>   RDMA/odp: remove ib_ucontext from ib_umem
>   mm/mmu_notifiers: remove unregister_no_release

There was some conflict churn in the RDMA ODP patches vs what was used
to the patches from this series, I fixed it up. Now I'm waiting for
some testing feedback before pushing it to linux-next

Thanks,
Jason


Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70589C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:07:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C38F2083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:07:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="m4NbZWWv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C38F2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D53166B000C; Wed, 14 Aug 2019 12:07:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D040A6B000D; Wed, 14 Aug 2019 12:07:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF1ED6B000E; Wed, 14 Aug 2019 12:07:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9EE6B000C
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:07:49 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 50E578248AA5
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:07:49 +0000 (UTC)
X-FDA: 75821514258.12.pot82_7e6eeb54a5450
X-HE-Tag: pot82_7e6eeb54a5450
X-Filterd-Recvd-Size: 5209
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:07:48 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id u34so11390815qte.2
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:07:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uSze5gwW1/nHV7sdPnwR3jTf0rLBBMNUn/+CnX7OfxQ=;
        b=m4NbZWWvLvFaknX0xdkPpgAtWEaAV8BPlNsV0QPnc6RgrYDmgG7AIsCG9ZHupO1OhY
         MK5GQaw5bosgo81D9cY6GHmq179L4OqwHK3M6QUinKEJeDqx/XxsudgIdbj6JCJJ8Mx4
         OEfKzvMu4bctJ4ELd7APkdehLFO1/45kAPB31gtLMFMBegBd1BaTmuRtXRxfaqmbb9j/
         7gcKiA8oYZgHtUpbyJxdB8Pj0Jf2ZLMQcL7IdGdjMoAq6vEQba2nasxNHi3QIdWTLTQH
         d/4ioF5GVIgVwgwhmehLPTTzbIryOo6apF1QStiPEI+ww2ZIZ0Kt7coH71+5OeY3wmmM
         wQUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=uSze5gwW1/nHV7sdPnwR3jTf0rLBBMNUn/+CnX7OfxQ=;
        b=nCDVIvl3U02pOQCaffZwIzG8a+L0FuYe3GyhFnXe49W7VlkWSi+pHv2XDU33D+MIkg
         kxL5cmo4vV3HLb1gKKgmSzgfaxIRhAPGcYcZ5GVqk0+Q0PawGFC37+h2CRXAMS4jXuoJ
         ZY+3H8F+hJCgplS7Ld7Pki9AabzrzYjYXBbuIdDUSm/tC9vLgJ/sdvviXrIuZWzbhZHV
         zjS5PvFI42JTdQ0N9H8wUPTpgm/18GikSgt9ESgiB3NSzlpRP5kxbpGUZWLBweL6fgHd
         PwkWtCuNNGqRaz+XulVu8bAS4AtXsxO6RFTAUdizEr6wLiRUYRUhS8h0qzlsZy8bSAq5
         qD+g==
X-Gm-Message-State: APjAAAWipffPA86E2guW0mLngIZdjY2H6fZ8S7ZVaB1kBAQYAV9erfBO
	DkfiwY7Bt2ultznO4hqd4vwpI87vE0g=
X-Google-Smtp-Source: APXvYqyb9m87zjH3q35GhpgQm6CNCVSjTDXOgvHlJfjkQScATNdsG/TvzCk00mXmdZUVCVz5HTGwYA==
X-Received: by 2002:a0c:af33:: with SMTP id i48mr323000qvc.185.1565798867959;
        Wed, 14 Aug 2019 09:07:47 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id h26sm52286qta.58.2019.08.14.09.07.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 09:07:47 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hxvoR-0001J4-0D; Wed, 14 Aug 2019 13:07:47 -0300
Date: Wed, 14 Aug 2019 13:07:46 -0300
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
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org
Subject: Re: [PATCH v3 hmm 08/11] drm/radeon: use mmu_notifier_get/put for
 struct radeon_mn
Message-ID: <20190814160746.GA4926@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-9-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-9-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:15:45PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> radeon is using a device global hash table to track what mmu_notifiers
> have been registered on struct mm. This is better served with the new
> get/put scheme instead.
> 
> radeon has a bug where it was not blocking notifier release() until all
> the BO's had been invalidated. This could result in a use after free of
> pages the BOs. This is tied into a second bug where radeon left the
> notifiers running endlessly even once the interval tree became
> empty. This could result in a use after free with module unload.
> 
> Both are fixed by changing the lifetime model, the BOs exist in the
> interval tree with their natural lifetimes independent of the mm_struct
> lifetime using the get/put scheme. The release runs synchronously and just
> does invalidate_start across the entire interval tree to create the
> required DMA fence.
> 
> Additions to the interval tree after release are already impossible as
> only current->mm is used during the add.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>  drivers/gpu/drm/radeon/radeon.h        |   3 -
>  drivers/gpu/drm/radeon/radeon_device.c |   2 -
>  drivers/gpu/drm/radeon/radeon_drv.c    |   2 +
>  drivers/gpu/drm/radeon/radeon_mn.c     | 157 ++++++-------------------
>  4 files changed, 38 insertions(+), 126 deletions(-)

AMD team: Are you OK with this patch?

Jason


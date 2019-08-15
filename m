Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28533C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:13:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE6F1208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 00:13:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kQ7rO4Rr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE6F1208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7568A6B0007; Wed, 14 Aug 2019 20:13:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DDCA6B0008; Wed, 14 Aug 2019 20:13:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CC966B000A; Wed, 14 Aug 2019 20:13:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 3554D6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 20:13:22 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id ACEB340C5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:13:21 +0000 (UTC)
X-FDA: 75822737802.30.night76_2cf2e1a9753
X-HE-Tag: night76_2cf2e1a9753
X-Filterd-Recvd-Size: 4808
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 00:13:21 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id s145so567241qke.7
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:13:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qzhD8inHCWGPsSExfxoS4FMI+7+fcQwlxaBDgT12qb4=;
        b=kQ7rO4RrHFSZ6MZuuxxoF8VbnBnjRycJLb07elyvEnUiIa4wJgsVinEba3cE2MqTB9
         fJulQuWx6Y5tYTxlddWTc11PBfISadqD+ExfUHnpoPQON92Ku+S5Y/WG1rnAqUDmFm/t
         sZdh11B/5WH1wkWaQw580ROrmY5paRB/mKD6yO6YRdOAjXFOKeMa/lNRNHsDHR11a2YM
         fH5CrO9kz+3OETBgm2cIOfKwCC5iyZs6YtbJwN/rErrCwql6u7WwlNfS1W19r/IYCdLa
         OB/xGbNt8+DZYg3Zcz43LE9VgkFuylrF77Y+9lVNSAp5BzomHMMBV2AknnHcgTQXagXw
         j3Dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=qzhD8inHCWGPsSExfxoS4FMI+7+fcQwlxaBDgT12qb4=;
        b=gJWNcedIddL9X4ZrCQnmDbnz/tnQ5CbqStg3AitSOq5Vh5w13LNOfB91JLKXz/lfoj
         olTsFaCL3Hg8tATdhQP4wjEoZ7QurVTYi4cUrAA1cAQYK7Ub0VhKJe+/GXRrGlOBWNWA
         r5VrhRyjJM+ZFZJ8TBN0X5bKmteUXffDA9OCF7js3AAjbh6seScrC9I4d1pwn+vT/9L5
         ZLX/ShPS9lNik+jSa72Ce9qNbH7TJalixgCY5tBYWvLTW3+YYP8GDPOMbkRostKZl2fb
         w78VWqFg0clsHWi93QNzdtkaote3HFFRF8PhbPXMsq+fLznsNgcYjaSys8s0uWKF+vO3
         5dMQ==
X-Gm-Message-State: APjAAAWWeuxTF1GBaIta32jxQSmUIeDSd3hvadCaGW02Ffy1nX1Tu+iu
	wEVzQ7VjinSf1O9WKDYfmBj4rg==
X-Google-Smtp-Source: APXvYqxctXlgOtCTuI+nHfly9zVzKydMCFWuaFknzokpvDUX3JdzMaNu+TsBvuyQsnsSgXcVbMLc+w==
X-Received: by 2002:a05:620a:130d:: with SMTP id o13mr1851841qkj.285.1565828000618;
        Wed, 14 Aug 2019 17:13:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i5sm756517qti.0.2019.08.14.17.13.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 17:13:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hy3OJ-0003bl-SN; Wed, 14 Aug 2019 21:13:19 -0300
Date: Wed, 14 Aug 2019 21:13:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>, John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 hmm 03/11] mm/mmu_notifiers: add a get/put scheme for
 the registration
Message-ID: <20190815001319.GF11200@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-4-jgg@ziepe.ca>
 <0a23adb8-b827-cd90-503e-bfa84166c67e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0a23adb8-b827-cd90-503e-bfa84166c67e@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 02:20:31PM -0700, Ralph Campbell wrote:
> 
> On 8/6/19 4:15 PM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > Many places in the kernel have a flow where userspace will create some
> > object and that object will need to connect to the subsystem's
> > mmu_notifier subscription for the duration of its lifetime.
> > 
> > In this case the subsystem is usually tracking multiple mm_structs and it
> > is difficult to keep track of what struct mmu_notifier's have been
> > allocated for what mm's.
> > 
> > Since this has been open coded in a variety of exciting ways, provide core
> > functionality to do this safely.
> > 
> > This approach uses the strct mmu_notifier_ops * as a key to determine if
> 
> s/strct/struct

Yes, thanks for all of this, I like having comments, but I'm a
terrible proofreader :(

Jason


Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E03DFC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:29:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADB6B2173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:29:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADB6B2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 351406B0007; Thu,  8 Aug 2019 06:29:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 303106B0008; Thu,  8 Aug 2019 06:29:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 218306B000A; Thu,  8 Aug 2019 06:29:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF36C6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 06:29:54 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b1so44959101wru.4
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:29:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Co76/uxCxhCHTb0pV+eGVxgciZkJsfESPyPOdVWAD6w=;
        b=X1SALW6HyysUVra/w59iIXz7M7cpaBdMMBjr3VpTRwKQSYkmLMs1s6S8xAGKZd2ZzH
         tqVkm4ZQIM8xPB2gPI1i3aYZR5+JJaOQJgC+sAnhM4woNvmg1LRCiYBYM96O2eKJ9uhO
         NHxbcRDEw/c+NVoJALs3MeOkpQs8MAQSIeS5sOrlL7/e0N9NEajjLnlMkV6s/HhAFZRF
         H9QRP/CsczWgNAuH3OWOEPf8t3KgqA6uwz9I/71L1pY5wsuRUk2MC68rmuyN/flNS+tw
         vh/JRK42OKkncRLNDlvgibGyvJx4CC8ZMV3BIslwlwvVwLx8mwv3tBYyOPJb5GeklHHa
         C62A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVpuJTQ2HIx3wA9b7f408yz6DiOFjzfK/wOasUnFCnfq9AEIzLq
	AstBdhiAHq6mEOsD7p4acNs3judTEA5lQ68AKJd4Z/a4WqJYvSPCNiWDrCdPFN5rHoYfT1QXU3u
	7qBc6UQ71QaFSN+jKhFpwvjeWqmP+m4bWxmwbyRwOsPMMVT9/AgecDBG5Lgbs7fPKwQ==
X-Received: by 2002:adf:ea03:: with SMTP id q3mr2829917wrm.219.1565260194531;
        Thu, 08 Aug 2019 03:29:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqf9dRsQND8QEouEhNWC0IpRRHAkyQ5e1WMIgLCDuwi24dXlKwgSqfS6zheyYeihxp9kh3
X-Received: by 2002:adf:ea03:: with SMTP id q3mr2829853wrm.219.1565260193909;
        Thu, 08 Aug 2019 03:29:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565260193; cv=none;
        d=google.com; s=arc-20160816;
        b=PB09OUtoG65wSsx6dQoW0bykSWhTuUPz/eaVT52ULg7VuYxL14MwECObHvrgCzzjwJ
         AAdjLK5fTkqxPAMAytaawTUx19tzxirayz44RJS4I1K/SC6oNDotAaAM55OfZTTjAtQh
         bgwOgp7rPy6BCCMYkVbFMW+d+w59FJyPwaueaTK56v0fmJy7sJw0JBeZZuMcwzKUFGtm
         Cj6SzSW0A/W3vA0t56ECicIMlO2nl92ZIoSeQRyfZ7dOkjac2By/fTTYN1LggdVm4bAX
         9VfFQ61mZFyx9iwvUAo5Vv/8mEHm2xdS8TLuacky/XZce7qC1wF0U09uy+lofTwAQ9pw
         AwUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Co76/uxCxhCHTb0pV+eGVxgciZkJsfESPyPOdVWAD6w=;
        b=FXQDJbpt/0BBqUDd4xGCCh3soPYKTg1doeKAlaw/mbGwoEcU7cfIJ6XqFzauSa5Q/7
         33H52RSttIgl87NYh9qs4315mVQW8T8LE//pCfX5VqWKmrpt7Tfw8qOMIV/aDcvETrcv
         cq5tyNXi3VRNyOvr8A2belbA2NKveEPc9UDtXiQqapCuEjtYp+iRj6jqScVYKRKM1ZJX
         M2SWu9M7B0cjPcppMHL1Bb/ZNnHFCTNQ8iAzXgYcfRi8pbbyEXR7MIya++Q6WLgvGoJv
         pNQel3nPjRq71XLk0AC59JyVr5oiLoH1rxFQxbd/H2XXGHfh0rncpGBKPJp3MyChJygg
         SxVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w2si895513wre.169.2019.08.08.03.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 03:29:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id ECABD227A81; Thu,  8 Aug 2019 12:29:51 +0200 (CEST)
Date: Thu, 8 Aug 2019 12:29:51 +0200
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
Subject: Re: [PATCH v3 hmm 11/11] mm/mmu_notifiers: remove
 unregister_no_release
Message-ID: <20190808102951.GE648@lst.de>
References: <20190806231548.25242-1-jgg@ziepe.ca> <20190806231548.25242-12-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-12-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:15:48PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> mmu_notifier_unregister_no_release() and mmu_notifier_call_srcu() no
> longer have any users, they have all been converted to use
> mmu_notifier_put().
> 
> So delete this difficult to use interface.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>


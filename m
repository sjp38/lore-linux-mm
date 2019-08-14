Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68F65C32757
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:53:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 211A82133F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:53:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="DuHQyhEk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 211A82133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C50916B0005; Wed, 14 Aug 2019 17:53:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDA9F6B0006; Wed, 14 Aug 2019 17:53:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8DF6B0007; Wed, 14 Aug 2019 17:53:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0158.hostedemail.com [216.40.44.158])
	by kanga.kvack.org (Postfix) with ESMTP id 890D56B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:53:47 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4BCB53A82
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:53:47 +0000 (UTC)
X-FDA: 75822386094.25.coal85_5b344a21bca3e
X-HE-Tag: coal85_5b344a21bca3e
X-Filterd-Recvd-Size: 3527
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:53:46 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5482f40000>; Wed, 14 Aug 2019 14:53:56 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 14 Aug 2019 14:53:45 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 14 Aug 2019 14:53:45 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 14 Aug
 2019 21:53:42 +0000
Subject: Re: [PATCH v3 hmm 11/11] mm/mmu_notifiers: remove
 unregister_no_release
To: Jason Gunthorpe <jgg@ziepe.ca>, <linux-mm@kvack.org>
CC: Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, "Alex
 Deucher" <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <iommu@lists.linux-foundation.org>,
	<intel-gfx@lists.freedesktop.org>, Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-12-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <84b35625-9877-0f35-155a-2d5ee1af4108@nvidia.com>
Date: Wed, 14 Aug 2019 14:53:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190806231548.25242-12-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565819636; bh=jn8qPKX3vGj+tzC7jfWRezHMQaQX7LZbuyruFud4LQQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=DuHQyhEkn2nVu3F9JE1Jqs394XgDiOloB/DupeDvogYw6EVbMONwcehm4ND30nlJe
	 coLB6ipCN1oIyc4w1mqCCYewK+PC5YV9u55ueYp2oaHr/1plVEnMB9PP5+CTSD2S+f
	 /EwXD2xqdd7b1DugwUAbPGKM94w9rldbIHus7fAOpSWXDg6bOvnb9bZD9px5zT4R9w
	 fNKaAnXFzpPWTG2T38iLy/xRORGPkKKaDbUB4Y5JUU/eQRUnl/o4i6ggHqZCwIPAQU
	 XR1OQDE52UPDPt8SmWG+WQaZO6Cc6+YdybR1YFmKROUzj521DapTNnEGLy+4532Itg
	 +dCm77lSoXV4A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/6/19 4:15 PM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> mmu_notifier_unregister_no_release() and mmu_notifier_call_srcu() no
> longer have any users, they have all been converted to use
> mmu_notifier_put().
> 
> So delete this difficult to use interface.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>


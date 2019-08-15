Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28A9AC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F37B72084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:28:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F37B72084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5D26B0284; Thu, 15 Aug 2019 09:28:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76E936B0286; Thu, 15 Aug 2019 09:28:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65D5B6B0287; Thu, 15 Aug 2019 09:28:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB336B0284
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:28:50 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E982C2C22
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:28:49 +0000 (UTC)
X-FDA: 75824742378.12.linen47_6a2576255cb06
X-HE-Tag: linen47_6a2576255cb06
X-Filterd-Recvd-Size: 1681
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:28:49 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id D963768B05; Thu, 15 Aug 2019 15:28:45 +0200 (CEST)
Date: Thu, 15 Aug 2019 15:28:45 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: turn hmm migrate_vma upside down v3
Message-ID: <20190815132845.GC12036@lst.de>
References: <20190814075928.23766-1-hch@lst.de> <8e3b17ef-0b9e-6866-128f-403c8ba3a322@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8e3b17ef-0b9e-6866-128f-403c8ba3a322@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 05:09:54PM -0700, Ralph Campbell wrote:
> Some of the patches seem to have been mangled in the mail.

Weird, I never had such a an issue with git-send-email.

But to be covered for such weird cases I also posted a git url
for exactly the tree I've been working on.

> I was able to edit them and apply to Jason's tree
> https://github.com/jgunthorpe/linux.git mmu_notifier branch.
> So for the series you can add:
>
> Tested-by: Ralph Campbell <rcampbell@nvidia.com>

Thanks!


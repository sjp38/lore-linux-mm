Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25E3AC3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 22:38:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3090206BB
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 22:37:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3090206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 678A76B04ED; Sat, 24 Aug 2019 18:37:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6273E6B04EF; Sat, 24 Aug 2019 18:37:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53C866B04F0; Sat, 24 Aug 2019 18:37:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id 2D84C6B04ED
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 18:37:59 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BE274181AC9AE
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 22:37:58 +0000 (UTC)
X-FDA: 75858785436.25.birds03_287fa35a77123
X-HE-Tag: birds03_287fa35a77123
X-Filterd-Recvd-Size: 1667
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 22:37:58 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 5FED368B02; Sun, 25 Aug 2019 00:37:54 +0200 (CEST)
Date: Sun, 25 Aug 2019 00:37:54 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] mm/hmm: hmm_range_fault() NULL pointer bug
Message-ID: <20190824223754.GA21891@lst.de>
References: <20190823221753.2514-1-rcampbell@nvidia.com> <20190823221753.2514-2-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823221753.2514-2-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 03:17:52PM -0700, Ralph Campbell wrote:
> Although hmm_range_fault() calls find_vma() to make sure that a vma exists
> before calling walk_page_range(), hmm_vma_walk_hole() can still be called
> with walk->vma == NULL if the start and end address are not contained
> within the vma range.

Should we convert to walk_vma_range instead?  Or keep walk_page_range
but drop searching the vma ourselves?

Except for that the patch looks good to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>


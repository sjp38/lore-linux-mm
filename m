Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B76BEC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 07:40:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A8E82085A
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 07:40:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A8E82085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCF1F6B0003; Mon, 12 Aug 2019 03:40:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7FAD6B0005; Mon, 12 Aug 2019 03:40:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6E1E6B0006; Mon, 12 Aug 2019 03:40:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5836B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 03:40:39 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 323AE75A0
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 07:40:39 +0000 (UTC)
X-FDA: 75812978598.11.day18_5ced562991348
X-HE-Tag: day18_5ced562991348
X-Filterd-Recvd-Size: 1538
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 07:40:38 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 82E3568BFE; Mon, 12 Aug 2019 09:40:29 +0200 (CEST)
Date: Mon, 12 Aug 2019 09:40:29 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH 2/5] resource: add a not device managed
 request_free_mem_region variant
Message-ID: <20190812074029.GA4709@lst.de>
References: <20190811081247.22111-1-hch@lst.de> <20190811081247.22111-3-hch@lst.de> <20190811225252.GB15116@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190811225252.GB15116@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 11, 2019 at 10:52:58PM +0000, Jason Gunthorpe wrote:
> It is a bit jarring to have something called devm_* that doesn't
> actually do the devm_ part on some paths.
> 
> Maybe this function should be called __request_free_mem_region() with
> another name wrapper macro?

Seems like a little more churn than required, but I could do it.


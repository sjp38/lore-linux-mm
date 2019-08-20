Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FA4DC3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:26:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBE6D218BA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:26:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBE6D218BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 820526B0007; Mon, 19 Aug 2019 22:26:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D87C6B0008; Mon, 19 Aug 2019 22:26:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E6CC6B000A; Mon, 19 Aug 2019 22:26:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3876B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:26:24 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 05BEA45A4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:26:24 +0000 (UTC)
X-FDA: 75841217088.24.coal34_8f1f9c1aa7c5c
X-HE-Tag: coal34_8f1f9c1aa7c5c
X-Filterd-Recvd-Size: 1564
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:26:23 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9B59668B02; Tue, 20 Aug 2019 04:26:19 +0200 (CEST)
Date: Tue, 20 Aug 2019 04:26:19 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Ira Weiny <ira.weiny@intel.com>
Subject: Re: [PATCH 1/4] resource: add a not device managed
 request_free_mem_region variant
Message-ID: <20190820022619.GA23225@lst.de>
References: <20190818090557.17853-1-hch@lst.de> <20190818090557.17853-2-hch@lst.de> <CAPcyv4iaNtmvU5e8_8SV9XsmVCfnv8e7_YfMi46LfOF4W155zg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iaNtmvU5e8_8SV9XsmVCfnv8e7_YfMi46LfOF4W155zg@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 06:28:30PM -0700, Dan Williams wrote:
> 
> Previously we would loudly crash if someone passed NULL to
> devm_request_free_mem_region(), but now it will silently work and the
> result will leak. Perhaps this wants a:

We'd still instantly crash due to the dev_name dereference, right?


Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FDD6C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 07:40:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 798532085A
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 07:40:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 798532085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4FD6B0005; Mon, 12 Aug 2019 03:40:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A5C96B0006; Mon, 12 Aug 2019 03:40:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E3226B0008; Mon, 12 Aug 2019 03:40:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id EE98A6B0005
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 03:40:51 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9DA538248AA3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 07:40:51 +0000 (UTC)
X-FDA: 75812979102.11.gun10_5ec17b85e0a18
X-HE-Tag: gun10_5ec17b85e0a18
X-Filterd-Recvd-Size: 1413
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 07:40:51 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id F2F6768BFE; Mon, 12 Aug 2019 09:40:47 +0200 (CEST)
Date: Mon, 12 Aug 2019 09:40:47 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH 5/5] memremap: provide a not device managed
 memremap_pages
Message-ID: <20190812074047.GB4709@lst.de>
References: <20190811081247.22111-1-hch@lst.de> <20190811081247.22111-6-hch@lst.de> <20190811225601.GC15116@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190811225601.GC15116@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 11, 2019 at 10:56:07PM +0000, Jason Gunthorpe wrote:
> > + * This version is not intended for system resources only, and there is no
> 
> Was 'is not' what was intended here? I'm having a hard time reading
> this.

s/not//g


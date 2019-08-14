Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B60CEC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 06:11:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92DB42084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 06:11:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92DB42084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DE3C6B0007; Wed, 14 Aug 2019 02:11:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2687C6B0008; Wed, 14 Aug 2019 02:11:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 156E16B000A; Wed, 14 Aug 2019 02:11:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id E145E6B0007
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:11:55 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8EEC4181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:11:55 +0000 (UTC)
X-FDA: 75820012590.21.offer64_10bd6495db718
X-HE-Tag: offer64_10bd6495db718
X-Filterd-Recvd-Size: 1769
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 06:11:54 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 20CAC68B02; Wed, 14 Aug 2019 08:11:51 +0200 (CEST)
Date: Wed, 14 Aug 2019 08:11:50 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 5/5] memremap: provide a not device managed
 memremap_pages
Message-ID: <20190814061150.GA24835@lst.de>
References: <20190811081247.22111-1-hch@lst.de> <20190811081247.22111-6-hch@lst.de> <20190812145058.GA16950@in.ibm.com> <20190812150012.GA12700@lst.de> <20190813045611.GB16950@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813045611.GB16950@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 10:26:11AM +0530, Bharata B Rao wrote:
> Yes, this patchset works non-modular and with kvm-hv as module, it
> works with devm_memremap_pages_release() and release_mem_region() in the
> cleanup path. The cleanup path will be required in the non-modular
> case too for proper recovery from failures.

Can you check if the version here:

    git://git.infradead.org/users/hch/misc.git pgmap-remove-dev

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/pgmap-remove-dev

works for you fully before I resend?

> 
> Regards,
> Bharata.
---end quoted text---


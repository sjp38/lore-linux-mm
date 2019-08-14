Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85295C41514
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:25:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A65B208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 11:25:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A65B208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3A816B0005; Wed, 14 Aug 2019 07:25:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC47A6B0006; Wed, 14 Aug 2019 07:25:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB26C6B0007; Wed, 14 Aug 2019 07:25:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0033.hostedemail.com [216.40.44.33])
	by kanga.kvack.org (Postfix) with ESMTP id B596A6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 07:25:40 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C3D6E8248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:25:39 +0000 (UTC)
X-FDA: 75820803198.14.low61_88aeee9fc0540
X-HE-Tag: low61_88aeee9fc0540
X-Filterd-Recvd-Size: 1826
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:25:39 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7757D68B02; Wed, 14 Aug 2019 13:25:35 +0200 (CEST)
Date: Wed, 14 Aug 2019 13:25:35 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 5/5] memremap: provide a not device managed
 memremap_pages
Message-ID: <20190814112535.GA2339@lst.de>
References: <20190811081247.22111-1-hch@lst.de> <20190811081247.22111-6-hch@lst.de> <20190812145058.GA16950@in.ibm.com> <20190812150012.GA12700@lst.de> <20190813045611.GB16950@in.ibm.com> <20190814061150.GA24835@lst.de> <20190814085826.GB8784@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814085826.GB8784@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 02:28:26PM +0530, Bharata B Rao wrote:
> >     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/pgmap-remove-dev
> > 
> > works for you fully before I resend?
> 
> Yes, this works for us. This and migrate-vma-cleanup series helps to
> really simplify the kvmppc secure pages management code. Thanks.

Thanks.  I'm going to resend it once we've made a bit of progress
on the migrate_vma series that I resent this morning.  There are
a few more lose ends in this area with implications for the driver
API, so I might have a few more patches for you to test in a bit.


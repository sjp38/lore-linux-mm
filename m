Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77B40C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:36:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 510F420644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:36:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 510F420644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 004C26B0005; Fri, 16 Aug 2019 08:36:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED0B86B000A; Fri, 16 Aug 2019 08:36:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE5526B000C; Fri, 16 Aug 2019 08:36:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id B72A06B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:36:11 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6E7188248ABE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:36:11 +0000 (UTC)
X-FDA: 75828238542.22.sea92_8d4d2c8223045
X-HE-Tag: sea92_8d4d2c8223045
X-Filterd-Recvd-Size: 1584
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:36:10 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8145268B05; Fri, 16 Aug 2019 14:36:07 +0200 (CEST)
Date: Fri, 16 Aug 2019 14:36:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: add a not device managed memremap_pages v2
Message-ID: <20190816123607.GA22681@lst.de>
References: <20190816065434.2129-1-hch@lst.de> <20190816123356.GE5412@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816123356.GE5412@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > Changes since v1:
> >  - don't overload devm_request_free_mem_region
> >  - export the memremap_pages and munmap_pages as kvmppc can be a module
> 
> What tree do we want this to go through? Dan are you running a pgmap
> tree still? Do we know of any conflicts?

The last changes in this area went through the hmm tree.  There are
now known conflicts, and the kvmppc drivers that needs this already
has a dependency on the hmm tree for the migrate_vma_* changes.


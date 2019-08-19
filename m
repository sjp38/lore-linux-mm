Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 094DAC3A59D
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 06:30:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC64520851
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 06:30:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC64520851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C7166B0008; Mon, 19 Aug 2019 02:30:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2771D6B000A; Mon, 19 Aug 2019 02:30:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18E1F6B000C; Mon, 19 Aug 2019 02:30:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id E61FF6B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 02:30:21 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 80FF7612B
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 06:30:21 +0000 (UTC)
X-FDA: 75838203042.13.sink54_202ad663d502d
X-HE-Tag: sink54_202ad663d502d
X-Filterd-Recvd-Size: 1892
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 06:30:20 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 0548B68B20; Mon, 19 Aug 2019 08:30:16 +0200 (CEST)
Date: Mon, 19 Aug 2019 08:30:15 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: add a not device managed memremap_pages v3
Message-ID: <20190819063015.GA20248@lst.de>
References: <20190818090557.17853-1-hch@lst.de> <20190819052752.GD8784@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819052752.GD8784@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 10:57:52AM +0530, Bharata B Rao wrote:
> On Sun, Aug 18, 2019 at 11:05:53AM +0200, Christoph Hellwig wrote:
> > Hi Dan and Jason,
> > 
> > Bharata has been working on secure page management for kvmppc guests,
> > and one I thing I noticed is that he had to fake up a struct device
> > just so that it could be passed to the devm_memremap_pages
> > instrastructure for device private memory.
> > 
> > This series adds non-device managed versions of the
> > devm_request_free_mem_region and devm_memremap_pages functions for
> > his use case.
> 
> Tested kvmppc ultravisor patchset with migrate_vma changes and this
> patchset. (Had to manually patch mm/memremap.c instead of kernel/memremap.c
> though)

Oh.  I rebased to the hmm tree, and that didn't have the rename yet.
And I didn't even notice that as git handled it transparently.


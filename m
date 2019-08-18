Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C81C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:03:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 508DC2086C
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:03:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 508DC2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C2746B0008; Sun, 18 Aug 2019 05:03:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 972676B000A; Sun, 18 Aug 2019 05:03:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 888C96B000C; Sun, 18 Aug 2019 05:03:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0010.hostedemail.com [216.40.44.10])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1136B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 05:03:40 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 0730F8248AC1
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:03:40 +0000 (UTC)
X-FDA: 75834960600.25.play46_2d5a8c6d2457
X-HE-Tag: play46_2d5a8c6d2457
X-Filterd-Recvd-Size: 1692
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:03:39 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 175DB227A81; Sun, 18 Aug 2019 11:03:35 +0200 (CEST)
Date: Sun, 18 Aug 2019 11:03:34 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Bharata B Rao <bharata@linux.ibm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 1/4] resource: add a not device managed
 request_free_mem_region variant
Message-ID: <20190818090334.GA20462@lst.de>
References: <20190816065434.2129-1-hch@lst.de> <20190816065434.2129-2-hch@lst.de> <20190816140134.1f3225bed9bf2734c03341b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816140134.1f3225bed9bf2734c03341b1@linux-foundation.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 02:01:34PM -0700, Andrew Morton wrote:
> On Fri, 16 Aug 2019 08:54:31 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > Just add a simple macro that passes a NULL dev argument to
> > dev_request_free_mem_region, and call request_mem_region in the
> > function for that particular case.
> 
> Nit:
> 
> > +struct resource *request_free_mem_region(struct resource *base,
> > +		unsigned long size, const char *name);
> 
> This isn't a macro ;)

Oops, the changelog needs updating vs the first version of course.


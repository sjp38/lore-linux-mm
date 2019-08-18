Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A6EC3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 150EE2086C
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:04:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 150EE2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B47896B000A; Sun, 18 Aug 2019 05:04:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF7846B000C; Sun, 18 Aug 2019 05:04:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5C446B000D; Sun, 18 Aug 2019 05:04:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 87B4B6B000A
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 05:04:41 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 352618787
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:04:41 +0000 (UTC)
X-FDA: 75834963162.03.kite46_bc2eefcee82f
X-HE-Tag: kite46_bc2eefcee82f
X-Filterd-Recvd-Size: 1711
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:04:40 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 974F1227A81; Sun, 18 Aug 2019 11:04:37 +0200 (CEST)
Date: Sun, 18 Aug 2019 11:04:37 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Bharata B Rao <bharata@linux.ibm.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 4/4] memremap: provide a not device managed
 memremap_pages
Message-ID: <20190818090437.GB20462@lst.de>
References: <20190816065434.2129-1-hch@lst.de> <20190816065434.2129-5-hch@lst.de> <20190816140057.c1ab8b41b9bfff65b7ea83ba@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816140057.c1ab8b41b9bfff65b7ea83ba@linux-foundation.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 02:00:57PM -0700, Andrew Morton wrote:
> On Fri, 16 Aug 2019 08:54:34 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > The kvmppc ultravisor code wants a device private memory pool that is
> > system wide and not attached to a device.  Instead of faking up one
> > provide a low-level memremap_pages for it.  Note that this function is
> > not exported, and doesn't have a cleanup routine associated with it to
> > discourage use from more driver like users.
> 
> Confused. Which function is "not exported"?

Leftover from v1 and dropped now.


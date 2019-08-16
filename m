Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB296C3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 23:59:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A9FE20665
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 23:59:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A9FE20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6C906B0007; Fri, 16 Aug 2019 19:59:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1E976B000A; Fri, 16 Aug 2019 19:59:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0B0E6B000C; Fri, 16 Aug 2019 19:59:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id 99EEA6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:59:32 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 50B518248AD0
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 23:59:32 +0000 (UTC)
X-FDA: 75829960584.28.lake62_8d574f700d54c
X-HE-Tag: lake62_8d574f700d54c
X-Filterd-Recvd-Size: 2293
Received: from mga04.intel.com (mga04.intel.com [192.55.52.120])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 23:59:31 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Aug 2019 16:59:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,395,1559545200"; 
   d="scan'208";a="328823005"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 16 Aug 2019 16:59:28 -0700
Date: Fri, 16 Aug 2019 16:59:27 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	Bharata B Rao <bharata@linux.ibm.com>
Subject: Re: add a not device managed memremap_pages v2
Message-ID: <20190816235927.GB11384@iweiny-DESK2.sc.intel.com>
References: <20190816065434.2129-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816065434.2129-1-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 08:54:30AM +0200, Christoph Hellwig wrote:
> Hi Dan and Jason,
> 
> Bharata has been working on secure page management for kvmppc guests,
> and one I thing I noticed is that he had to fake up a struct device
> just so that it could be passed to the devm_memremap_pages
> instrastructure for device private memory.
> 
> This series adds non-device managed versions of the
> devm_request_free_mem_region and devm_memremap_pages functions for
> his use case.
> 
> Changes since v1:
>  - don't overload devm_request_free_mem_region
>  - export the memremap_pages and munmap_pages as kvmppc can be a module

Except for the questions from Andrew this does not look to change anything so:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm


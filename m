Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id AE69282F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 11:13:18 -0400 (EDT)
Received: by ioii196 with SMTP id i196so80170152ioi.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 08:13:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id n6si10832264ige.76.2015.09.24.08.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 08:13:17 -0700 (PDT)
Date: Thu, 24 Sep 2015 08:13:16 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 07/15] devm_memremap: convert to return ERR_PTR
Message-ID: <20150924151316.GE24375@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044150.36490.15073.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923044150.36490.15073.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-nvdimm@ml01.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Sep 23, 2015 at 12:41:50AM -0400, Dan Williams wrote:
> Make devm_memremap consistent with the error return scheme of
> devm_memremap_pages to remove special casing in the pmem driver.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

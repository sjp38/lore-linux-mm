Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91F59440D03
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:01:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v88so4567238wrb.22
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:01:20 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d83si768899wmc.72.2017.11.10.01.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 01:01:19 -0800 (PST)
Date: Fri, 10 Nov 2017 10:01:19 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/3] IB/core: disable memory registration of
	fileystem-dax vmas
Message-ID: <20171110090119.GB4895@lst.de>
References: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com> <151001624138.16354.16836728315400060928.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151001624138.16354.16836728315400060928.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>, stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-mm@kvack.org, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>

On Mon, Nov 06, 2017 at 04:57:21PM -0800, Dan Williams wrote:
> Until there is a solution to the dma-to-dax vs truncate problem it is
> not safe to allow RDMA to create long standing memory registrations
> against filesytem-dax vmas.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

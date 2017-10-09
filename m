Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3216B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:59:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so8189435pfj.21
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:59:05 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id g69si7544821ita.125.2017.10.09.11.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 11:59:04 -0700 (PDT)
Date: Mon, 9 Oct 2017 12:58:40 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v7 07/12] dma-mapping: introduce dma_has_iommu()
Message-ID: <20171009185840.GB15336@obsidianresearch.com>
References: <150732931273.22363.8436792888326501071.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150732935473.22363.1853399637339625023.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Oct 06, 2017 at 03:35:54PM -0700, Dan Williams wrote:
> otherwise be quiesced. The need for this knowledge is driven by a need
> to make RDMA transfers to DAX mappings safe. If the DAX file's block map
> changes we need to be to reliably stop accesses to blocks that have been
> freed or re-assigned to a new file.

If RDMA is driving this need, why not invalidate backing RDMA MRs
instead of requiring a IOMMU to do it? RDMA MR are finer grained and
do not suffer from the re-use problem David W. brought up with IOVAs..

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BB066B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:36:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so1813349wmd.0
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:36:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n82sor762058wmf.57.2017.11.29.10.36.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 10:36:19 -0800 (PST)
Date: Wed, 29 Nov 2017 11:36:13 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v3 4/4] IB/core: disable memory registration of
 fileystem-dax vmas
Message-ID: <20171129183613.GD4011@ziepe.ca>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151197875158.26211.7203330105253426435.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151197875158.26211.7203330105253426435.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-nvdimm@lists.01.org, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>, stable@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>

On Wed, Nov 29, 2017 at 10:05:51AM -0800, Dan Williams wrote:
> Until there is a solution to the dma-to-dax vs truncate problem it is
> not safe to allow RDMA to create long standing memory registrations
> against filesytem-dax vmas.
> 
> Cc: Sean Hefty <sean.hefty@intel.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: <linux-rdma@vger.kernel.org>
> Cc: <stable@vger.kernel.org>
> Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
> Reported-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>  drivers/infiniband/core/umem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

No problem here with drivers/rdma. This will go through another tree
with the rest of the series? In which case here is a co-maintainer ack
for this patch:

Acked-by: Jason Gunthorpe <jgg@mellanox.com>

Dan, can you please update my address to jgg@ziepe.ca, thanks :)

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

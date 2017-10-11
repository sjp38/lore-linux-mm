Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C0F3C6B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 20:46:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d28so935330pfe.2
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:46:36 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id h71si9085858pgc.321.2017.10.10.17.46.33
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 17:46:35 -0700 (PDT)
Date: Wed, 11 Oct 2017 11:46:31 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v8 04/14] xfs: prepare xfs_break_layouts() for reuse with
 MAP_DIRECT
Message-ID: <20171011004631.GX3666@dastard>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150764695771.16882.9179160793491582514.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150764695771.16882.9179160793491582514.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, iommu@lists.linux-foundation.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Tue, Oct 10, 2017 at 07:49:17AM -0700, Dan Williams wrote:
> Move xfs_break_layouts() to its own compilation unit so that it can be
> used for both pnfs layouts and MAP_DIRECT mappings.
.....
> diff --git a/fs/xfs/xfs_pnfs.h b/fs/xfs/xfs_pnfs.h
> index b587cb99b2b7..4135b2482697 100644
> --- a/fs/xfs/xfs_pnfs.h
> +++ b/fs/xfs/xfs_pnfs.h
> @@ -1,19 +1,13 @@
>  #ifndef _XFS_PNFS_H
>  #define _XFS_PNFS_H 1
>  
> +#include "xfs_layout.h"
> +

I missed this the first time through - we try not to put includes
in header files, and instead make sure each C file has all the
includes they require. Can you move this to all the C files that
need layouts and remove the include of the xfs_pnfs.h include from
them?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

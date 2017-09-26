Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 729786B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:16:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so22516716pgn.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:16:41 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 82si5925001pfn.379.2017.09.26.10.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 10:16:40 -0700 (PDT)
Date: Tue, 26 Sep 2017 11:16:38 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 2/7] xfs: validate bdev support for DAX inode flag
Message-ID: <20170926171638.GA20159@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-3-ross.zwisler@linux.intel.com>
 <20170926063650.GE6870@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926063650.GE6870@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 08:36:50AM +0200, Christoph Hellwig wrote:
> On Mon, Sep 25, 2017 at 05:13:59PM -0600, Ross Zwisler wrote:
> > Currently only the blocksize is checked, but we should really be calling
> > bdev_dax_supported() which also tests to make sure we can get a
> > struct dax_device and that the dax_direct_access() path is working.
> > 
> > This is the same check that we do for the "-o dax" mount option in
> > xfs_fs_fill_super().
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> I think we just want to pick this up ASAP.  And between my vague
> memoried and that reviewed-by tag it already was part of a different
> series, wasn't it?

Yep, the first 2 patches were part of this series:

https://lkml.org/lkml/2017/9/7/552

which you reviewed.  I included them in this series because the later patches
needed to build on them.  It looks like they are now in Darrick's
xfs-4.14-fixes branch, but haven't yet made it upstream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

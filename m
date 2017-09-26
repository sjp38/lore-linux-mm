Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6978C6B0253
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:36:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r136so10852137wmf.4
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 23:36:52 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u19si6342409wru.527.2017.09.25.23.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 23:36:51 -0700 (PDT)
Date: Tue, 26 Sep 2017 08:36:50 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/7] xfs: validate bdev support for DAX inode flag
Message-ID: <20170926063650.GE6870@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-3-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-3-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 05:13:59PM -0600, Ross Zwisler wrote:
> Currently only the blocksize is checked, but we should really be calling
> bdev_dax_supported() which also tests to make sure we can get a
> struct dax_device and that the dax_direct_access() path is working.
> 
> This is the same check that we do for the "-o dax" mount option in
> xfs_fs_fill_super().
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

I think we just want to pick this up ASAP.  And between my vague
memoried and that reviewed-by tag it already was part of a different
series, wasn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

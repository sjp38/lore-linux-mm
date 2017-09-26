Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86C706B025E
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 15:01:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m30so22921605pgn.2
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 12:01:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k8si6266577pga.495.2017.09.26.12.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 12:01:54 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:01:51 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 7/7] xfs: re-enable XFS per-inode DAX
Message-ID: <20170926190151.GC31146@linux.intel.com>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com>
 <20170925231404.32723-8-ross.zwisler@linux.intel.com>
 <20170926063611.GD6870@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926063611.GD6870@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 26, 2017 at 08:36:11AM +0200, Christoph Hellwig wrote:
> On Mon, Sep 25, 2017 at 05:14:04PM -0600, Ross Zwisler wrote:
> > Re-enable the XFS per-inode DAX flag, preventing S_DAX from changing when
> > any mappings are present.
> 
> Before we re-enable it please come up with a coherent description
> of the per-inode DAX flag that makes sense to a user.  We'll also need
> to find a good place to document it, e.g. a new ioctl_setflags man
> page.

I agree that documentation is a great place to start, if we can just agree on
what we want the functionality to be. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

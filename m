Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6B56B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:36:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y83so953231wmc.2
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 23:36:13 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 189si1070649wmv.21.2017.09.25.23.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 23:36:12 -0700 (PDT)
Date: Tue, 26 Sep 2017 08:36:11 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 7/7] xfs: re-enable XFS per-inode DAX
Message-ID: <20170926063611.GD6870@lst.de>
References: <20170925231404.32723-1-ross.zwisler@linux.intel.com> <20170925231404.32723-8-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170925231404.32723-8-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, "J. Bruce Fields" <bfields@fieldses.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Sep 25, 2017 at 05:14:04PM -0600, Ross Zwisler wrote:
> Re-enable the XFS per-inode DAX flag, preventing S_DAX from changing when
> any mappings are present.

Before we re-enable it please come up with a coherent description
of the per-inode DAX flag that makes sense to a user.  We'll also need
to find a good place to document it, e.g. a new ioctl_setflags man
page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

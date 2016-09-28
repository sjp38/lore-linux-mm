Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62FC928025C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 00:56:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j69so79700519itb.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 21:56:01 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id e193si7851604iof.159.2016.09.27.21.55.59
        for <linux-mm@kvack.org>;
        Tue, 27 Sep 2016 21:56:00 -0700 (PDT)
Date: Wed, 28 Sep 2016 14:55:50 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 00/11] re-enable DAX PMD support
Message-ID: <20160928045550.GF27872@dastard>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
 <20160928020842.GA4428@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928020842.GA4428@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 27, 2016 at 07:08:42PM -0700, Christoph Hellwig wrote:
> On Tue, Sep 27, 2016 at 02:47:51PM -0600, Ross Zwisler wrote:
> > DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> > locking.  This series allows DAX PMDs to participate in the DAX radix tree
> > based locking scheme so that they can be re-enabled.
> > 
> > Jan and Christoph, can you please help review these changes?
> 
> About to get on a plane, so it might take a bit to do a real review.
> In general this looks fine, but I guess the first two ext4 patches
> should just go straight to Ted independent of the rest?
> 
> Also Jan just posted a giant DAX patchbomb, we'll need to find a way
> to integrate all that work, and maybe prioritize things if we want
> to get bits into 4.9 still.

I'm not going to have time to do much review or testing of the DAX
changes (apart from the cursor comments I've already made) because
of the huge pile of XFS reflink changes I've got ot get through
first. However, I've already got the iomap dax bits in the XFS tree
so I can pull everything through there if review and testing is
covered otherwise......

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

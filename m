Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 700226B0282
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:08:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 21so65441038pfy.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 19:08:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id fn10si5628153pab.94.2016.09.27.19.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 19:08:53 -0700 (PDT)
Date: Tue, 27 Sep 2016 19:08:42 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 00/11] re-enable DAX PMD support
Message-ID: <20160928020842.GA4428@infradead.org>
References: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-xfs@vger.kernel.org

On Tue, Sep 27, 2016 at 02:47:51PM -0600, Ross Zwisler wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This series allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled.
> 
> Jan and Christoph, can you please help review these changes?

About to get on a plane, so it might take a bit to do a real review.
In general this looks fine, but I guess the first two ext4 patches
should just go straight to Ted independent of the rest?

Also Jan just posted a giant DAX patchbomb, we'll need to find a way
to integrate all that work, and maybe prioritize things if we want
to get bits into 4.9 still.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

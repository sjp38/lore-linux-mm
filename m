Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83ECC6B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 12:37:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d64so87157123wmh.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 09:37:56 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id a2si3127873wme.84.2016.10.03.09.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 09:37:55 -0700 (PDT)
Date: Mon, 3 Oct 2016 18:37:54 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v4 10/12] dax: add struct iomap based DAX PMD support
Message-ID: <20161003163754.GB1496@lst.de>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com> <1475189370-31634-11-git-send-email-ross.zwisler@linux.intel.com> <20161003105949.GP6457@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003105949.GP6457@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Oct 03, 2016 at 12:59:49PM +0200, Jan Kara wrote:
> I'm not quite sure if it is OK to call ->iomap_begin() without ever calling
> ->iomap_end. Specifically the comment before iomap_apply() says:
> 
> "It is assumed that the filesystems will lock whatever resources they
> require in the iomap_begin call, and release them in the iomap_end call."
> 
> so what you do could result in unbalanced allocations / locks / whatever.
> Christoph?

Indeed.  For XFS we only rely on iomap_end for error handling at the
moment, but it is intended to be paired for locking, as cluster file
systems like gfs2 requested this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

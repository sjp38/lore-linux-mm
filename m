Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 396026B0261
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 11:50:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y38so70094689qta.6
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 08:50:31 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id xb6si6960005wjb.31.2016.10.10.08.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 08:50:30 -0700 (PDT)
Date: Mon, 10 Oct 2016 17:50:29 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 14/17] dax: move RADIX_DAX_* defines to dax.h
Message-ID: <20161010155029.GE19343@lst.de>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com> <1475874544-24842-15-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475874544-24842-15-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Fri, Oct 07, 2016 at 03:09:01PM -0600, Ross Zwisler wrote:
> The RADIX_DAX_* defines currently mostly live in fs/dax.c, with just
> RADIX_DAX_ENTRY_LOCK being in include/linux/dax.h so it can be used in
> mm/filemap.c.  When we add PMD support, though, mm/filemap.c will also need
> access to the RADIX_DAX_PTE type so it can properly construct a 4k sized
> empty entry.
> 
> Instead of shifting the defines between dax.c and dax.h as they are
> individually used in other code, just move them wholesale to dax.h so
> they'll be available when we need them.

Looks fine, assuming that the macros get cleaned up in the next patches..

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

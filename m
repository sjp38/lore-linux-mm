Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 8444B6B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 02:57:24 -0400 (EDT)
Date: Tue, 15 May 2012 02:57:18 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] xfs: hole-punch use truncate_pagecache_range
Message-ID: <20120515065718.GA7373@infradead.org>
References: <alpine.LSU.2.00.1205131347120.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205131347120.1547@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Ben Myers <bpm@sgi.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 13, 2012 at 01:50:06PM -0700, Hugh Dickins wrote:
> When truncating a file, we unmap pages from userspace first, as that's
> usually more efficient than relying, page by page, on the fallback in
> truncate_inode_page() - particularly if the file is mapped many times.
> 
> Do the same when punching a hole: 3.4 added truncate_pagecache_range()
> to do the unmap and trunc, so use it in xfs_flushinval_pages(), instead
> of calling truncate_inode_pages_range() directly.

This change looks fine.

> Should xfs_tosspages() be using it too?  I don't know: left unchanged.

I'll look at it.  I've been planning to simplify and/or kill the
xfs_fs_subr.c wrappers which tend to confuse the code for a while now,
and deciding what exactly to do should be a fallout from that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

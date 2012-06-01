Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 2A63C6B005A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 00:17:47 -0400 (EDT)
Date: Fri, 1 Jun 2012 00:17:42 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] ext4: hole-punch use truncate_pagecache_range
Message-ID: <20120601041742.GG7897@thunk.org>
References: <alpine.LSU.2.00.1205131342420.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205131342420.1547@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 13, 2012 at 01:47:00PM -0700, Hugh Dickins wrote:
> When truncating a file, we unmap pages from userspace first, as that's
> usually more efficient than relying, page by page, on the fallback in
> truncate_inode_page() - particularly if the file is mapped many times.
> 
> Do the same when punching a hole: 3.4 added truncate_pagecache_range()
> to do the unmap and trunc, so use it in ext4_ext_punch_hole(), instead
> of calling truncate_inode_pages_range() directly.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Applied, thanks.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

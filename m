Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id BEF376B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 17:03:19 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7400872dak.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 14:03:18 -0700 (PDT)
Date: Sun, 13 May 2012 14:03:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm for fs: add truncate_pagecache_range
In-Reply-To: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205131354380.1547@eggly.anvils>
References: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Becker <jlbec@evilplan.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012, Hugh Dickins wrote:
> I do have patches for ext4, ocfs2 and xfs to use this, but they're too
> late now for v3.4.  However, it would be helpful if this function could
> go ahead into v3.4, so filesystems can convert to it at leisure afterwards.

I just sent out the little ext4 and xfs patches, but decided not
to bother you with the ocfs2 one.  ocfs2 is already doing it right with
unmap_mapping_range; and since file.c is using unmap_mapping_range with
truncate_inode_pages in other places, it seemed wrong to force a different
convention upon you in this one place (perhaps they can all be converted
to truncate_pagecache_range, but if it ain't broke...)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A01946B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:25:13 -0400 (EDT)
Date: Thu, 17 May 2012 02:25:00 -0700
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [PATCH] mm for fs: add truncate_pagecache_range
Message-ID: <20120517092459.GB6773@dhcp-172-17-9-228.mtv.corp.google.com>
References: <alpine.LSU.2.00.1203231343380.1940@eggly.anvils>
 <alpine.LSU.2.00.1205131354380.1547@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205131354380.1547@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 13, 2012 at 02:03:03PM -0700, Hugh Dickins wrote:
> On Fri, 23 Mar 2012, Hugh Dickins wrote:
> > I do have patches for ext4, ocfs2 and xfs to use this, but they're too
> > late now for v3.4.  However, it would be helpful if this function could
> > go ahead into v3.4, so filesystems can convert to it at leisure afterwards.
> 
> I just sent out the little ext4 and xfs patches, but decided not
> to bother you with the ocfs2 one.  ocfs2 is already doing it right with
> unmap_mapping_range; and since file.c is using unmap_mapping_range with
> truncate_inode_pages in other places, it seemed wrong to force a different
> convention upon you in this one place (perhaps they can all be converted
> to truncate_pagecache_range, but if it ain't broke...)

Works for me.  Thanks.

Joel

> 
> Hugh

-- 

"There are only two ways to live your life. One is as though nothing
 is a miracle. The other is as though everything is a miracle."
        - Albert Einstein

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

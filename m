Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB7528D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:40:21 -0400 (EDT)
Date: Thu, 21 Apr 2011 00:40:08 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/6] NFS: return -EAGAIN when skipped commit in
 nfs_commit_unstable_pages()
Message-ID: <20110421044008.GD22423@infradead.org>
References: <20110419030003.108796967@intel.com>
 <20110419030532.902141228@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419030532.902141228@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 19, 2011 at 11:00:09AM +0800, Wu Fengguang wrote:
> It's probably not sane to return success while redirtying the inode at
> the same time in ->write_inode().

It is not, as it really confuses the writeback code. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

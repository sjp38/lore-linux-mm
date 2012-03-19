Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B927B6B00E9
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 02:57:45 -0400 (EDT)
Date: Mon, 19 Mar 2012 02:57:39 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] fs: Remove bogus wait in write_inode_now()
Message-ID: <20120319065739.GA11113@infradead.org>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
 <1331283748-12959-2-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331283748-12959-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 09, 2012 at 10:02:25AM +0100, Jan Kara wrote:
> inode_sync_wait() in write_inode_now() is just bogus. That function waits for
> I_SYNC bit to be cleared but writeback_single_inode() clears the bit on return
> so the wait is effectivelly a nop unless someone else submits the inode for
> writeback again. All the waiting write_inode_now() needs is achieved by using
> WB_SYNC_ALL writeback mode.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Loks good - I have the same in my patchkit to kill write_inode_now
(which I really need to get out soon).

Signed-off-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

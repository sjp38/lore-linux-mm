Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6E8716B00EA
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 02:58:25 -0400 (EDT)
Date: Mon, 19 Mar 2012 02:58:21 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/4] writeback: Remove outdated comment
Message-ID: <20120319065821.GB11113@infradead.org>
References: <1331283748-12959-1-git-send-email-jack@suse.cz>
 <1331283748-12959-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331283748-12959-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 09, 2012 at 10:02:26AM +0100, Jan Kara wrote:
> The comment is hopelessly outdated and misplaced. We no longer have 'bdi'
> part of writeback work, the comment about blockdev super is outdated,
> comment about throttling as well. Information about list handling is in
> more detail at queue_io(). So just move the bit about older_than_this to
> close to move_expired_inodes() and remove the rest.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

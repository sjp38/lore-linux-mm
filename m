Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 044B89000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 10:59:37 -0400 (EDT)
Date: Wed, 28 Sep 2011 10:58:57 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/18] IO-less dirty throttling v11
Message-ID: <20110928145857.GA15587@infradead.org>
References: <20110904015305.367445271@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110904015305.367445271@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Sep 04, 2011 at 09:53:05AM +0800, Wu Fengguang wrote:
> Hi,
> 
> Finally, the complete IO-less balance_dirty_pages(). NFS is observed to perform
> better or worse depending on the memory size. Otherwise the added patches can
> address all known regressions.
> 
>         git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v11
> 	(to be updated; currently it contains a pre-release v11)

Fengguang,

is there any chance we could start doing just the IO-less
balance_dirty_pages, but not all the subtile other changes?  I.e. are
the any known issues that make things work than current mainline if we
only put in patches 1 to 6?  We're getting close to another merge
window, and we're still busy trying to figure out all the details of
the bandwith estimation.  I think we'd have a much more robust tree
if we'd first only merge the infrastructure (IO-less
balance_dirty_pages()) and then work on the algorithms separately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

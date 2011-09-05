Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 391596B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 05:42:57 -0400 (EDT)
Date: Mon, 5 Sep 2011 05:42:52 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 11/13] dcache: use a dispose list in select_parent
Message-ID: <20110905094252.GA28967@infradead.org>
References: <1314089786-20535-1-git-send-email-david@fromorbit.com>
 <1314089786-20535-12-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314089786-20535-12-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, khlebnikov@openvz.org

> -/**
>   * shrink_dcache_sb - shrink dcache for a superblock
>   * @sb: superblock
>   *
> @@ -1073,7 +1054,7 @@ EXPORT_SYMBOL(have_submounts);
>   * drop the lock and return early due to latency
>   * constraints.
>   */
> -static long select_parent(struct dentry * parent)
> +static long select_parent(struct dentry *parent, struct list_head *dispose)

Btw, the function header comment above select_parent is entirely
incorrect after your changes.

Also I'd suggest folding select_parent into shrink_dcache_parent as
the split doesn't make a whole lot of sense any more.  Maybe factoring
it at a different level would make sense, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

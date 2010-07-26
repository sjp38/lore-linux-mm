Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 113086006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:47:55 -0400 (EDT)
Date: Mon, 26 Jul 2010 19:47:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] [RFC] writeback: try to write older pages first
Message-ID: <20100726114724.GE6284@localhost>
References: <20100722050928.653312535@intel.com>
 <20100726192837.1cac842e.kitayama@cl.bb4u.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100726192837.1cac842e.kitayama@cl.bb4u.ne.jp>
Sender: owner-linux-mm@kvack.org
To: Itaru Kitayama <kitayama@cl.bb4u.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Here's a touch up patch on top of your changes against the latest
> mmotm.
>
> Signed-off-by: Itaru Kitayama <kitayama@cl.bb4u.ne.jp>

Applied, Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

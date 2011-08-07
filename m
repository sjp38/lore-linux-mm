Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 635306B016B
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 02:45:11 -0400 (EDT)
Date: Sun, 7 Aug 2011 14:44:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110807064459.GB3287@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
 <20110806144834.GA29243@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110806144834.GA29243@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > +             bw = (u64)base_bw * bw >> BANDWIDTH_CALC_SHIFT;
> > +             pause = (HZ * pages_dirtied + bw / 2) / (bw | 1);
> > +             pause = min(pause, MAX_PAUSE);
> 
> Fix this build warning:
> 
>  mm/page-writeback.c: In function a??balance_dirty_pagesa??:
>  mm/page-writeback.c:889:11: warning: comparison of distinct pointer types lacks a cast

Thanks! I'll fix it by changing `pause' to "long", since we'll have
negative pause time anyway when considering think time compensation.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 872426B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 08:07:38 -0400 (EDT)
Date: Fri, 26 Aug 2011 20:07:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 08/10] writeback: trace balance_dirty_pages
Message-ID: <20110826120733.GB26666@localhost>
References: <20110826113813.895522398@intel.com>
 <20110826114619.661085405@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110826114619.661085405@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> +	TP_printk("bdi %s: "
> +		  "limit=%lu goal=%lu dirty=%lu "
> +		  "bdi_goal=%lu bdi_dirty=%lu "
> +		  "base_rate=%lu task_ratelimit=%lu "
> +		  "dirtied=%u dirtied_pause=%u "
> +		  "period=%lu think=%ld pause=%ld paused=%lu",

Sorry, forgot the rename: base_rate => dirty_ratelimit.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 026B66B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 22:55:20 -0500 (EST)
Date: Wed, 10 Nov 2010 11:55:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: stop background/kupdate works from
 livelocking other works
Message-ID: <20101110035516.GA12710@localhost>
References: <20101110023500.404859581@intel.com>
 <20101110024223.847210776@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110024223.847210776@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Jan, the below comment is also updated, please double check.

>  
>  		/*
> +		 * Background writeout and kupdate-style writeback may
> +		 * run forever. Stop them if there is other work to do
> +		 * so that e.g. sync can proceed. They'll be restarted
> +		 * after the other works are all done.
> +		 */
> +		if ((work->for_background || work->for_kupdate) &&
> +		    !list_empty(&wb->bdi->work_list))
> +			break;
> +
> +		/*
>  		 * For background writeout, stop when we are below the
>  		 * background dirty threshold
>  		 */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

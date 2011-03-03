Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39F558D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:05:37 -0500 (EST)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PvB1x-00012Y-Vv
	for linux-mm@kvack.org; Thu, 03 Mar 2011 16:05:34 +0000
Subject: Re: [PATCH 09/27] nfs: writeback pages wait queue
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110303074949.809203319@intel.com>
References: <20110303064505.718671603@intel.com>
	 <20110303074949.809203319@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 17:07:00 +0100
Message-ID: <1299168420.1310.55.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 2011-03-03 at 14:45 +0800, Wu Fengguang wrote:
> +static void nfs_wait_contested(int is_sync,
> +                              struct backing_dev_info *bdi,
> +                              wait_queue_head_t *wqh) 

s/contested/congested/ ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

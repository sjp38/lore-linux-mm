Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2B04C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 20:53:20 -0500 (EST)
Date: Fri, 4 Mar 2011 09:53:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/27] nfs: writeback pages wait queue
Message-ID: <20110304015312.GA7976@localhost>
References: <20110303064505.718671603@intel.com>
 <20110303074949.809203319@intel.com>
 <1299168420.1310.55.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299168420.1310.55.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 04, 2011 at 12:07:00AM +0800, Peter Zijlstra wrote:
> On Thu, 2011-03-03 at 14:45 +0800, Wu Fengguang wrote:
> > +static void nfs_wait_contested(int is_sync,
> > +                              struct backing_dev_info *bdi,
> > +                              wait_queue_head_t *wqh) 
> 
> s/contested/congested/ ?

Good catch. Will update in another email.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

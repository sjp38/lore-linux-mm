Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 53CD28D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 04:11:40 -0500 (EST)
Subject: Re: [PATCH 09/27] nfs: writeback pages wait queue
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110304020157.GB7976@localhost>
References: <20110303064505.718671603@intel.com>
	 <20110303074949.809203319@intel.com> <1299168481.1310.56.camel@laptop>
	 <20110304020157.GB7976@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 04 Mar 2011 10:10:43 +0100
Message-ID: <1299229843.2428.13484.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Chris Mason <chris.mason@oracle.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-03-04 at 10:01 +0800, Wu Fengguang wrote:
>                         clear_bdi_congested(bdi, BLK_RW_SYNC);
>                         /*
>                          * On the following wake_up(), nfs_wait_congested=
()
>                          * will see the cleared bit and quit.
>                          */
>                         smp_mb__after_clear_bit();
>                 }
>                 if (waitqueue_active(&wqh[BLK_RW_SYNC]))
>                         wake_up(&wqh[BLK_RW_SYNC]);=20

If I tell you that: try_to_wake_up() implies an smp_wmb(), do you then
still need this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

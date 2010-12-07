Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6EDB76B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 12:35:08 -0500 (EST)
Message-ID: <4CFE7015.3070000@redhat.com>
Date: Tue, 07 Dec 2010 12:34:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: safety margin for bdi stat errors
References: <20101205064430.GA15027@localhost> <4CFB9BE1.3030902@redhat.com> <20101207131136.GA20366@localhost>
In-Reply-To: <20101207131136.GA20366@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 12/07/2010 08:11 AM, Wu Fengguang wrote:

> So the root cause is, the bdi_dirty is well under nr_dirty due to
> accounting errors. They should be very close because there is only one
> heavy dirtied bdi in the system. This can be fixed by using
> bdi_stat_sum(), however that's costly on large NUMA machines. So do a
> less costly fix of lowering the bdi limit, so that the accounting
> errors won't lead to the absurd situation "global limit exceeded but
> bdi limit not exceeded".
>
> CC: Rik van Riel<riel@redhat.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

I like this simple approach.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

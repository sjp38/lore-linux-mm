Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 21E196B009C
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 09:22:20 -0500 (EST)
Message-ID: <4D0B71DF.9080804@redhat.com>
Date: Fri, 17 Dec 2010 09:21:19 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: skip balance_dirty_pages() for in-memory fs
References: <20101213144646.341970461@intel.com> <20101213150329.002158963@intel.com> <20101217021934.GA9525@localhost> <alpine.LSU.2.00.1012162239270.23229@sister.anvils> <20101217112111.GA8323@localhost>
In-Reply-To: <20101217112111.GA8323@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 12/17/2010 06:21 AM, Wu Fengguang wrote:
> This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.
>
> It also prevents
>
> [  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
>
> in the balance_dirty_pages tracepoint, which will call
>
> 	dev_name(mapping->backing_dev_info->dev)
>
> but shmem_backing_dev_info.dev is NULL.
>
> CC: Hugh Dickins<hughd@google.com>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

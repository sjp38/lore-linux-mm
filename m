Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 690F36B009C
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 10:34:07 -0500 (EST)
Received: by iyj17 with SMTP id 17so508350iyj.14
        for <linux-mm@kvack.org>; Fri, 17 Dec 2010 07:34:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101217112111.GA8323@localhost>
References: <20101213144646.341970461@intel.com>
	<20101213150329.002158963@intel.com>
	<20101217021934.GA9525@localhost>
	<alpine.LSU.2.00.1012162239270.23229@sister.anvils>
	<20101217112111.GA8323@localhost>
Date: Sat, 18 Dec 2010 00:34:04 +0900
Message-ID: <AANLkTima=Tqkga6RzWepLt_H6ooqZappcqZB4MKk546J@mail.gmail.com>
Subject: Re: [PATCH] writeback: skip balance_dirty_pages() for in-memory fs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2010 at 8:21 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.
>
> It also prevents
>
> [ =A0388.126563] BUG: unable to handle kernel NULL pointer dereference at=
 0000000000000050
>
> in the balance_dirty_pages tracepoint, which will call
>
> =A0 =A0 =A0 =A0dev_name(mapping->backing_dev_info->dev)
>
> but shmem_backing_dev_info.dev is NULL.
>
> CC: Hugh Dickins <hughd@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Is it a material for -stable?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E05E6B0093
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 16:16:14 -0500 (EST)
Subject: Re: [PATCH 29/35] nfs: in-commit pages accounting and wait queue
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20101213150329.831955132@intel.com>
References: <20101213144646.341970461@intel.com>
	 <20101213150329.831955132@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 13 Dec 2010 16:15:51 -0500
Message-ID: <1292274951.8795.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> plain text document attachment (writeback-nfs-in-commit.patch)
> When doing 10+ concurrent dd's, I observed very bumpy commits submission
> (partly because the dd's are started at the same time, and hence reached
> 4MB to-commit pages at the same time). Basically we rely on the server
> to complete and return write/commit requests, and want both to progress
> smoothly and not consume too many pages. The write request wait queue is
> not enough as it's mainly network bounded. So add another commit request
> wait queue. Only async writes need to sleep on this queue.
>=20

I'm not understanding the above reasoning. Why should we serialise
commits at the per-filesystem level (and only for non-blocking flushes
at that)?

Cheers
  Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

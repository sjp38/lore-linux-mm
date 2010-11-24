Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 532CF6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 07:46:50 -0500 (EST)
Subject: Re: [PATCH 08/13] writeback: quit throttling when bdi dirty pages
 dropped low
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101124123023.GA10413@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.245782303@intel.com> <1290597233.2072.454.camel@laptop>
	 <20101124123023.GA10413@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 13:46:51 +0100
Message-ID: <1290602811.2072.462.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 20:30 +0800, Wu Fengguang wrote:
>=20
> For the 1-dd case, it looks better to lower the break threshold to
> 125ms. After all, it's not easy for the dirty pages to drop by 250ms
> worth of data when you only slept 200ms (note: the max pause time has
> been doubled mainly for servers).
>=20
> -               if (nr_dirty < dirty_thresh &&
> -                   bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwid=
th / 4)
> +               if (nr_dirty <=3D dirty_thresh &&
> +                   bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwid=
th / 8)
>                         break;

Hrm, but 125ms worth in 200ms is rather easy, you'd want to keep that
limit above what the pause should give you, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id IAA18523
	for <linux-mm@kvack.org>; Sun, 10 Nov 2002 08:58:28 -0800 (PST)
Message-ID: <3DCE9034.6F833C31@digeo.com>
Date: Sun, 10 Nov 2002 08:58:28 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.46-mm2
References: <3DCDD9AC.C3FB30D9@digeo.com> <20021110143208.GJ31134@suse.de> <20021110145203.GH23425@holomorphy.com> <20021110145757.GK31134@suse.de> <20021110150626.GI23425@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Jens Axboe <axboe@suse.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Sun, Nov 10, 2002 at 03:32:08PM +0100, Jens Axboe wrote:
> >>> I've attached a small document describing the deadline io scheduler
> >>> tunables. stream_unit is not in Andrew's version, yet, it uses a hard
> >>> defined 128KiB. Also, Andrew didn't apply the rbtree patch only the
> >>> tunable patch. So it uses the same insertion algorithm as the default
> >>> kernel, two linked lists.
> 
> On Sun, Nov 10 2002, William Lee Irwin III wrote:
> >> Okay, then I'll want the rbtree code for benchmarking.
> 
> On Sun, Nov 10, 2002 at 03:57:57PM +0100, Jens Axboe wrote:
> > Sure, I want to talk akpm into merging the rbtree code for real. Or I
> > can just drop you my current version, if you want.
> 
> Go for it, I'm just trying to get tiobench to actually run (seems to
> have new/different "die from too many threads" behavior wrt. --threads).
> Dropping me a fresh kernel shouldn't slow anything down.

It could be the procps thing?  `tiobench --threads 256' shows up as a
single process in top and ps due to the new thread consolidation feature.
If you run `ps auxm' or hit 'H' in top, all is revealed.  Not my fave
feature that.

> Bill
> 
> P.S.:   elvtune gets hung for a long time, it says:
>         ioctl get: Inappropriate ioctl for device
>         did it schedule with something held and get out of deadlock free?

BLKELVGET/SET was removed
 
> P.P.S:  kgdb broke wchan reporting... investigating

?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

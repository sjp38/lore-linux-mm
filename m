Date: Sun, 10 Nov 2002 15:57:57 +0100
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.5.46-mm2
Message-ID: <20021110145757.GK31134@suse.de>
References: <3DCDD9AC.C3FB30D9@digeo.com> <20021110143208.GJ31134@suse.de> <20021110145203.GH23425@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021110145203.GH23425@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 10 2002, William Lee Irwin III wrote:
> On Sat, Nov 09 2002, Andrew Morton wrote:
> >> And Jens's rbtree-based insertion code for the request queue.  Which
> >> means that the queues can be grown a *lot* if people want to play with
> >> that.  The VM should be able to cope with it fine.
> 
> On Sun, Nov 10, 2002 at 03:32:08PM +0100, Jens Axboe wrote:
> > I've attached a small document describing the deadline io scheduler
> > tunables. stream_unit is not in Andrew's version, yet, it uses a hard
> > defined 128KiB. Also, Andrew didn't apply the rbtree patch only the
> > tunable patch. So it uses the same insertion algorithm as the default
> > kernel, two linked lists.
> 
> Okay, then I'll want the rbtree code for benchmarking.

Sure, I want to talk akpm into merging the rbtree code for real. Or I
can just drop you my current version, if you want.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

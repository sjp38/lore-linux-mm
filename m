Date: Sun, 10 Nov 2002 09:11:30 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.46-mm2
Message-ID: <20021110171130.GJ23425@holomorphy.com>
References: <3DCDD9AC.C3FB30D9@digeo.com> <20021110143208.GJ31134@suse.de> <20021110145203.GH23425@holomorphy.com> <20021110145757.GK31134@suse.de> <20021110150626.GI23425@holomorphy.com> <3DCE9034.6F833C31@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DCE9034.6F833C31@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Jens Axboe <axboe@suse.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Go for it, I'm just trying to get tiobench to actually run (seems to
>> have new/different "die from too many threads" behavior wrt. --threads).
>> Dropping me a fresh kernel shouldn't slow anything down.

On Sun, Nov 10, 2002 at 08:58:28AM -0800, Andrew Morton wrote:
> It could be the procps thing?  `tiobench --threads 256' shows up as a
> single process in top and ps due to the new thread consolidation feature.
> If you run `ps auxm' or hit 'H' in top, all is revealed.  Not my fave
> feature that.

Turns out monitoring things via /proc/ slowed it down by some ridiculous
factor while it was trying to spawn threads. 9 hours became less than 1s
when I stopped looking.


On Sun, Nov 10, 2002 at 08:58:28AM -0800, Andrew Morton wrote:
> BLKELVGET/SET was removed

Okay, looks like there's an fs to use to get at it with.


On Sun, Nov 10, 2002 at 08:58:28AM -0800, Andrew Morton wrote:
>> P.P.S:  kgdb broke wchan reporting... investigating

On Sun, Nov 10, 2002 at 08:58:28AM -0800, Andrew Morton wrote:
> ?

The wchan reporting needs to get taught about kern_schedule()
and user_schedule() so it can trim them off the stack, which
consists of moving them between scheduling_functions_start_here()
and scheduling_functions_end_here().


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

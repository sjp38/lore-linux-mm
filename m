Date: Sun, 10 Nov 2002 23:41:29 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.46-mm2
Message-ID: <20021111074129.GK23425@holomorphy.com>
References: <3DCDD9AC.C3FB30D9@digeo.com> <20021110143208.GJ31134@suse.de> <20021110145203.GH23425@holomorphy.com> <20021110145757.GK31134@suse.de> <20021110150626.GI23425@holomorphy.com> <20021110155851.GL31134@suse.de> <3DCEB5E7.5147A449@digeo.com> <20021111070400.GP31134@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021111070400.GP31134@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 11, 2002 at 08:04:00AM +0100, Jens Axboe wrote:
> I've already done exactly this (mempool per queue, global slab). I'll
> share it later today.
> But yes, lets see some numbers on huge queues first. Otherwise we can
> just fall back to using a decent 128/512 split for reads/writes, or
> whatever is a good split.

This just got real hard real fast and we'll be waiting at least a week
for "real" results from me.

Sorry, I can't fix vendor drivers on-demand. Recent SCSI changes broke
the out-of-tree crap and I don't have the driver and/or in-kernel SCSI/FC
expertise to deal with it.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C06A1600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:47:18 -0400 (EDT)
Date: Thu, 8 Apr 2010 21:46:36 +0200
From: Andreas Mohr <andi@lisas.de>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
Message-ID: <20100408194635.GA22583@rhlx01.hs-esslingen.de>
References: <20100404221349.GA18036@rhlx01.hs-esslingen.de> <20100405105319.GA16528@rhlx01.hs-esslingen.de> <20100407070050.GA10527@localhost> <20100407111702.GA3676@rhlx01.hs-esslingen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100407111702.GA3676@rhlx01.hs-esslingen.de>
Sender: owner-linux-mm@kvack.org
To: Andreas Mohr <andi@lisas.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 07, 2010 at 01:17:02PM +0200, Andreas Mohr wrote:
> Thank you for your reply, I'll test the patch ASAP (with large writes
> and Firefox sync mixed in), maybe this will improve things already.

Indeed, AFAICS this definitely seems MUCH better than before.
I had to do a full kernel rebuild (due to CONFIG_LOCALVERSION_AUTO
changes; with no changed configs though).
I threw some extra load into the mix (read 400MB instead of 300 through
USB1.1, ran gimp, grepped over the entire /usr partition etc.pp.),
so far not nearly as severe as before, and no OOMs either.
Launched Firefox some time after starting 400MB creation, pretty ok
still. Some annoying lags sometimes of course, but nothing absolutely
earth-shattering as experienced before.
Things really appear to be a LOT better.

OK, so which way to go?

Thanks a lot,

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

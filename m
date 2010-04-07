Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F42306B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 07:17:06 -0400 (EDT)
Date: Wed, 7 Apr 2010 13:17:02 +0200
From: Andreas Mohr <andi@lisas.de>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
Message-ID: <20100407111702.GA3676@rhlx01.hs-esslingen.de>
References: <20100404221349.GA18036@rhlx01.hs-esslingen.de> <20100405105319.GA16528@rhlx01.hs-esslingen.de> <20100407070050.GA10527@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100407070050.GA10527@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 07, 2010 at 03:00:50PM +0800, Wu Fengguang wrote:
> Many applications (this one and below) are stuck in
> wait_on_page_writeback(). I guess this is why "heavy write to
> irrelevant partition stalls the whole system".  They are stuck on page
> allocation. Your 512MB system memory is a bit tight, so reclaim
> pressure is a bit high, which triggers the wait-on-writeback logic.

"Your 512MB system memory is a bit tight".
Heh, try to survive making such a statement 15 years ago ;)
(but you likely meant this in the context of inducing a whopping 300MB write)

Thank you for your reply, I'll test the patch ASAP (with large writes
and Firefox sync mixed in), maybe this will improve things already.

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

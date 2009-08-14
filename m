Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D2C3C6B004F
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 16:13:47 -0400 (EDT)
Date: Fri, 14 Aug 2009 22:13:11 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH -rt] Fix kmap_high_get()
Message-ID: <20090814201311.GA453@pengutronix.de>
References: <1249810600-21946-3-git-send-email-u.kleine-koenig@pengutronix.de> <1250199243-18677-1-git-send-email-u.kleine-koenig@pengutronix.de> <1250258573.5241.1581.camel@twins> <alpine.LFD.2.00.0908141152290.10633@xanadu.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.LFD.2.00.0908141152290.10633@xanadu.home>
Sender: owner-linux-mm@kvack.org
To: Nicolas Pitre <nico@marvell.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, rt-users <linux-rt-users@vger.kernel.org>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello,

On Fri, Aug 14, 2009 at 11:58:59AM -0400, Nicolas Pitre wrote:
> On Fri, 14 Aug 2009, Peter Zijlstra wrote:
> 
> > As to the patch, its not quite right.
... on irc Peter and me agreed it's not that wrong :-)  Anyhow, I merged
the two patches to get the benefits from both.  See below.

> > From what I understand kmap_high_get() is used to pin a page's kmap iff
> > it has one, whereas the result of your patch seems to be that it'll
> > actually create one if its not found.
> 
> I don't have enough context to review this patch, but your understanding 
> of the kmap_high_get() purpose is right.
The patch with all it's dependencies based on -rc6 is available on

	git://git.pengutronix.de/git/ukl/linux-2.6.git kmap-testing

Niko:  Your review would be very welcome because neither Peter nor me
have a machine with highmem.

Best regards
Uwe

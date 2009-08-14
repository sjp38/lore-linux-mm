Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D8E476B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 11:58:57 -0400 (EDT)
Date: Fri, 14 Aug 2009 11:58:59 -0400 (EDT)
From: Nicolas Pitre <nico@marvell.com>
Subject: Re: [PATCH -rt] Fix kmap_high_get()
In-Reply-To: <1250258573.5241.1581.camel@twins>
Message-ID: <alpine.LFD.2.00.0908141152290.10633@xanadu.home>
References: <1249810600-21946-3-git-send-email-u.kleine-koenig@pengutronix.de>  <1250199243-18677-1-git-send-email-u.kleine-koenig@pengutronix.de> <1250258573.5241.1581.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: =?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>, Thomas Gleixner <tglx@linutronix.de>, rt-users <linux-rt-users@vger.kernel.org>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Li Zefan <lizf@cn.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Aug 2009, Peter Zijlstra wrote:

> As to the patch, its not quite right.
> 
> From what I understand kmap_high_get() is used to pin a page's kmap iff
> it has one, whereas the result of your patch seems to be that it'll
> actually create one if its not found.

I don't have enough context to review this patch, but your understanding 
of the kmap_high_get() purpose is right.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

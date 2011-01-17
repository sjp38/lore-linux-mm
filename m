Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 645208D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 09:10:56 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: hunting an IO hang
In-reply-to: <20110117051135.GI9506@random.random>
References: <1295225684-sup-7168@think> <AANLkTikBamG2NG6j-z9fyTx=mk6NXFEE7LpB5z9s6ufr@mail.gmail.com> <4D339C87.30100@fusionio.com> <1295228148-sup-7379@think> <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com> <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com> <1295229722-sup-6494@think> <20110116183000.cc632557.akpm@linux-foundation.org> <1295231547-sup-8036@think> <20110117051135.GI9506@random.random>
Date: Mon, 17 Jan 2011 09:10:15 -0500
Message-Id: <1295273312-sup-6780@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Excerpts from Andrea Arcangeli's message of 2011-01-17 00:11:35 -0500:

[ crashes under load ]

> 
> NOTE: with the last changes compaction is used for all order > 0 and
> even from kswapd, so you will now be able to trigger bugs in
> compaction or migration even with THP off. However I'm surprised that
> you have issues with compaction...

I know I mentioned this in another email, but it is kind of buried in
other context.  I reproduced my crash with CONFIG_COMPACTION and
CONFIG_MIGRATION off.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

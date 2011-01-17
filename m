Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E7AA38D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 10:03:32 -0500 (EST)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: hunting an IO hang
In-reply-to: <1295272970-sup-6500@think>
References: <AANLkTikBamG2NG6j-z9fyTx=mk6NXFEE7LpB5z9s6ufr@mail.gmail.com> <4D339C87.30100@fusionio.com> <1295228148-sup-7379@think> <AANLkTimp6ef0W_=ijW=CfH6iC1mQzW3gLr1LZivJ5Bmd@mail.gmail.com> <AANLkTimr3hN8SDmbwv98hkcVfWoh9tioYg4M+0yanzpb@mail.gmail.com> <1295229722-sup-6494@think> <20110116183000.cc632557.akpm@linux-foundation.org> <1295231547-sup-8036@think> <20110117102744.GA27152@csn.ul.ie> <1295269009-sup-7646@think> <20110117135059.GB27152@csn.ul.ie> <1295272970-sup-6500@think>
Date: Mon, 17 Jan 2011 10:02:47 -0500
Message-Id: <1295276272-sup-1788@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Excerpts from Chris Mason's message of 2011-01-17 09:07:40 -0500:

[ various crashes under load with current git ]

> 
> I did have CONFIG_COMPACTION off for my latest reproduce.  The last two
> have been corruption on the page->lru lists, maybe that'll help narrow
> our bisect pool down.

I've reverted 744ed1442757767ffede5008bb13e0805085902e, and
d8505dee1a87b8d41b9c4ee1325cd72258226fbc and the run has lasted longer
than any runs in the past.

I'll give this a few hours but they seem the most related to my various
crashes so far.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

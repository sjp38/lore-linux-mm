Received: from skynet.csn.ul.ie (skynet [136.201.105.2])
	by holly.csn.ul.ie (Postfix) with ESMTP id A91052B39A
	for <linux-mm@kvack.org>; Wed, 29 Aug 2001 10:55:27 +0100 (IST)
Received: from localhost (localhost [127.0.0.1])
	by skynet.csn.ul.ie (Postfix) with ESMTP id 373F0E88C
	for <linux-mm@kvack.org>; Wed, 29 Aug 2001 10:55:27 +0100 (IST)
Date: Wed, 29 Aug 2001 10:55:27 +0100 (IST)
From: Mel <mel@csn.ul.ie>
Subject: Brief introduction
Message-ID: <Pine.LNX.4.32.0108291050010.1979-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Linux-MM,

As part of a larger project, I am to write a small paper describing how
the Linux MM works, including the algorithms used and the O(whatever)
running time each of them takes. This includes everything from the
different ways of allocating memory, to swapping, to the individual
optimisations such as use-once. I will be starting with kernel 2.4.9 but
will do my best to keep up to date with the various patches that affect
the memory manager and will be lurking here on the list.

This in it's very early days so it'll be some time before I actually have
something to show, but if people have areas they would like to see
concentrated on or suggestions on what the most important sections to
highlight are, I would be glad to hear them.

As appaling as this may sound to some of you ;), this is purely a
documentation effort and I don't intend to submit patches yet except in
the unlikely event I notice something blatently wrong. When I am finished,
I hope to have something that will help people get a grip on how the MM
functions that isn't just "read the source"

Thanks for your time

-- 
		Mel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

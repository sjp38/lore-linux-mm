Received: from norran.net (roger@t7o43p8.telia.com [194.237.168.128])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id CAA09945
	for <linux-mm@kvack.org>; Wed, 5 Jul 2000 02:58:11 +0200 (CEST)
Message-ID: <3962874A.190AAC7E@norran.net>
Date: Wed, 05 Jul 2000 02:54:35 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: User mode stalls - can it be...?
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,


I have an idea why we get the stalls!

If we end up in a situation where our write attempts are rejected
due to lack of resources - we will continue happily with next and
next...

Count hits zero and we return

But kswapd finds out that there is more to do and calls another
shrink_mmap...
(and need_resched is not set due to lower priority)

Gives, busy wait in shrink_mmap until pages are written...

I tried to renice 15 kswapd with improved results (I am using my patched
kernels)
Another approach would be to always sleep...

/RogerL

(Sent privately to Quintela and Riel - but it might be of value for
 someone else too...)

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

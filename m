Received: from mail.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA21524
	for <linux-mm@kvack.org>; Sat, 5 Dec 1998 20:58:02 -0500
Subject: Re: [PATCH] VM improvements for 2.1.131
References: <Pine.LNX.3.96.981206011441.13041A-100000@mirkwood.dummy.home>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 05 Dec 1998 20:10:01 -0600
In-Reply-To: Rik van Riel's message of "Sun, 6 Dec 1998 01:34:16 +0100 (CET)"
Message-ID: <m1hfva9g1y.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

 
RR 	/* Don't allow too many pending pages in flight.. */
RR-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
RR+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
RR 		wait = 1;

How will this possibly work if we are using a swapfile 
and we always swap synchronously?

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org

Date: Tue, 29 Jun 1999 22:08:52 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.LNX.4.10.9906290032460.1588-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9906292205340.32426-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 1999, Andrea Arcangeli wrote:

For the record: the snapshot wasn't SMP safe.

> 	/*
>+	 * We can release the big kernel lock here since
>+	 * kswapd will see the page locked. -Andrea
>+	 */
>+	unlock_kernel();

This was a bit too early (pefectly ok for kswapd but not ok for the swap
cache SMP safety). We must first take over the swap cache and run
swap_count before be allowed to release the big kernel lock. So this
should be moved a bit lower...

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

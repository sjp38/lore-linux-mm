Date: Tue, 29 Jun 1999 14:32:41 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <14200.46476.994769.970340@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9906291420110.13586-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jun 1999, Stephen C. Tweedie wrote:

>Absolutely.  The important thing is to do enough swapping to make sure
>that unused data is not kicking around in memory.  Maybe you don't want

I know that sometime is the right thing do to.

But think also a difference scenario. You have a machine that only reads
all the time from a disk 10giga of data in loop. The data is so big and
you reference it so in round-robin that you have no chance to find one bit
of data in in the page-cache (but don't tell me to not use a lru-algorithm
:).

So what you gain? You find most of your task swapped out: when you click
netscape on the other desktop you find yourself stalled. Then you change
desktop, the program continue to read from disk in background, and then
you find stalled again the next time. In this case you gain _nothing_ from
swapping out netscape.

So I think we should make the swapout level to be at least configurable.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

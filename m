Date: Tue, 29 Jun 1999 00:57:42 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <14199.62834.984162.69753@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9906290053180.1588-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chuck Lever <cel@monkey.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Stephen C. Tweedie wrote:

>> if you need evidence that shrink_mmap() will keep a system running without
>> swapping, just run 2.3.8 :) :)
>
>2.3.8 shows up slower on several benchmarks because of its reluctance to
>swap.

Here the point is if you are swapping over your ramdisk or over my HD :).
Over my HD (system+swap all in the same IDE disk) you must _avoid_ to swap
at all costs if you care about performances. And btw with the clock
algorithm nobody can ever be sure to get a good swap/cache balance. With
the page-LRU code I have almost ready for 2.3.x (definitely stable for
2.2.x) instead we'll be sure to swapout only when there isn't plenty of
cache recyclable.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

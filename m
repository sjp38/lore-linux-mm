Date: Tue, 29 Jun 1999 00:59:52 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <14199.62047.543601.273526@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9906290058300.1588-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Chuck Lever <cel@monkey.org>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 1999, Stephen C. Tweedie wrote:

>Hi,
>
>On Mon, 28 Jun 1999 13:51:03 -0700 (PDT), kanoj@google.engr.sgi.com (Kanoj Sarcar) said:
>
>>> or perhaps the kernel could start more than one kswapd (one per swap
>>> partition?).  with my patch, regular processes never wait for swap out
>>> I/O, only kswapd does.
>
>This is a mistake: such blocking is one of the prime ways in which we
>can limit the rate at which processes can consume memory.

Agreed.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

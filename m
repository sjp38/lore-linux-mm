From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.62047.543601.273526@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:08:31 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <199906282051.NAA12151@google.engr.sgi.com>
References: <Pine.BSO.4.10.9906281625130.24888-100000@funky.monkey.org>
	<199906282051.NAA12151@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Chuck Lever <cel@monkey.org>, andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 13:51:03 -0700 (PDT), kanoj@google.engr.sgi.com (Kanoj Sarcar) said:

>> or perhaps the kernel could start more than one kswapd (one per swap
>> partition?).  with my patch, regular processes never wait for swap out
>> I/O, only kswapd does.

This is a mistake: such blocking is one of the prime ways in which we
can limit the rate at which processes can consume memory.

> Oh no, I was not talking about exotic stuff like RT ... I was 
> simply pointing out that to prevent deadlocks, and guarantee forward
> progress, you have to show that despite what underlying fs/driver
> code does, at least one memory freer is free to do its job. 

Yep, which is why we have a separate kpiod right now: it guarantees that
potential recursive fs locking stalls get shifted from kswapd to a
separate thread to make sure that kswapd can always make progress.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

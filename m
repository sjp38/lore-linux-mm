From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.62834.984162.69753@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:21:38 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <Pine.BSO.4.10.9906281715420.24888-100000@funky.monkey.org>
References: <199906282051.NAA12151@google.engr.sgi.com>
	<Pine.BSO.4.10.9906281715420.24888-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, andrea@suse.de, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 17:32:05 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> well, except that kswapd itself doesn't free any memory.  

It has to.  That was why kswapd was initially written, to ensure that
interrupt memory requests (eg. busy router boxes) don't starve of
memory.  All of the benefits of kswapd came later.  In normal kernels
the try_to_swap_out doesn't free memory, true enough, but kswapd calls
shrink_mmap() too to make sure it does make real progress in freeing
memory.

> if you need evidence that shrink_mmap() will keep a system running without
> swapping, just run 2.3.8 :) :)

2.3.8 shows up slower on several benchmarks because of its reluctance to
swap.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

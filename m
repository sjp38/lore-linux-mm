From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14200.43693.106414.697828@dukat.scot.redhat.com>
Date: Tue, 29 Jun 1999 12:14:53 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
In-Reply-To: <Pine.BSO.4.10.9906282052110.10964-100000@funky.monkey.org>
References: <14199.62047.543601.273526@dukat.scot.redhat.com>
	<Pine.BSO.4.10.9906282052110.10964-100000@funky.monkey.org>
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.3.96.990629092953.7614D@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 20:53:23 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> whoops.  i'm sorry, i mis-typed.  i meant that regular processes never
> *dispatch* I/O.  neither kswapd nor regular processes will wait.

Sorry?  That's just the same problem, restated.  If a regular process
will never wait on a memory allocation then you have no way of
throttling the memory allocation rate to the rate at which you can
swap stuff out.  That will kill your machine stone dead very rapidly
under heavy memory load.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

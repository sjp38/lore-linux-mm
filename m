Message-ID: <3850D27C.9291A8E4@ife.ee.ethz.ch>
Date: Fri, 10 Dec 1999 11:14:20 +0100
From: Thomas Sailer <sailer@ife.ee.ethz.ch>
MIME-Version: 1.0
Subject: Re: Getting big areas of memory, in 2.3.x?
References: <E11wDK1-0002nT-00@the-village.bc.nu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@chiara.csoma.elte.hu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:

> This is the main point. There are so so few devices that actually _have_ to
> have lots of linear memory it is questionable that it is worth paying the
> price to allow modules to allocate that way

Soundcard hardware wavetable synthesizers come in mind. There are very
few cards that do _not_ require multimegabyte contiguous memory.

But then again software synthesizers are realizable these days.

Tom
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

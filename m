Message-ID: <38502E4C.6B9AD5F4@mandrakesoft.com>
Date: Thu, 09 Dec 1999 17:33:48 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Getting big areas of memory, in 2.3.x?
References: <Pine.LNX.4.10.9912100021250.10946-100000@chiara.csoma.elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: "William J. Earl" <wje@cthulhu.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> yep, if eg. an fsck happened before modules are loaded then RAM is filled
> up with the buffer-cache. The best guarantee is to compile such drivers
> into the kernel.

Buffer cache is disposable memory, though...

-- 
Jeff Garzik              | Just once, I wish we would encounter
Building 1024            | an alien menace that wasn't immune to
MandrakeSoft, Inc.       | bullets.   -- The Brigadier, "Dr. Who"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

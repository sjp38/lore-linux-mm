Message-Id: <200003241742.MAA02123@ccure.karaya.com>
Subject: Re: madvise (MADV_FREE) 
In-Reply-To: Your message of "Fri, 24 Mar 2000 08:21:22 +0100."
             <38DB1772.5665EFA2@intermec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Fri, 24 Mar 2000 12:42:18 -0500
From: Jeff Dike <jdike@karaya.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lars brinkhoff <lars.brinkhoff@intermec.com>
Cc: lk@tantalophile.demon.co.uk, cel@monkey.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Per-page accessed and dirty information from the hosting kernel would
> ease the implementation of a simulated MMU.

> Perhaps also the user-mode Linux kernel would benefit, but I'm not
> sure. Jeff?

The user-mode kernel doesn't expect to get any mm bits from the hosting kernel 
and I don't see any use for them.  It lives in its own happy world keeping 
track of its own bits.

Maybe on arches where the hardware provides those bits and the kernel uses 
them, but the i386 kernel doesn't.

				Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

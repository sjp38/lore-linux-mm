Message-ID: <39109A1B.FBF98FA0@mandrakesoft.com>
Date: Wed, 03 May 2000 17:28:59 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005031110200.6180-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> We fixed one such bug in NFS. Maybe there are more lurking? How much
> memory do the machines have that have problems?

FWIW

Dual P-II w/ 128 MB of memory.  pre7-2 and pre7-3 (with #error removed)
both boot up and let me login ok -- I have an NFS automounted home dir. 
But... doing a lot of "netscaping" -- clicking around, opening new
windows, making the machine do lots of mmap() and swap -- causes the box
to lock hard.

I'm gonna hook up a serial console and see if I can get output.  Might
try booting w/ CONFIG_SMP/num-cpus==1 to see if that triggers any ugly
behavior too.

I'll also try to reproduce the problem without NFS in the picture.

	Jeff




-- 
Jeff Garzik              | Nothing cures insomnia like the
Building 1024            | realization that it's time to get up.
MandrakeSoft, Inc.       |        -- random fortune
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

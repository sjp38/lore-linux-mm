Message-Id: <200012292154.QAA17527@ninigret.metatel.office>
From: Rafal Boni <rafal.boni@eDial.com>
Subject: Re: 2.2.19pre3 and poor reponse to RT-scheduled processes? 
In-Reply-To: Your message of "Fri, 29 Dec 2000 16:19:28 EST."
             <20001229161927.A560@xi.linuxpower.cx>
Date: Fri, 29 Dec 2000 16:54:23 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

In message <20001229161927.A560@xi.linuxpower.cx>, Greg Maxwell wrote:

- -> You are running IDE aren't you?
- -> 
- -> Enable DMA and/or unmask interupts.

D'oh!  Thanks to Greg for the clue-by-four!  I *am* running IDE and I had
both DMA (due to misreading of kernel boot message) and interrupt unmasking 
(since I had forgotten that one) off....

I had assumed that DMA was on from the mention of it in kernel messages 
(which on closer reading do indicate CMOS/BIOS configured default modes,
not what the kernel is using), and the lack of an explicit message on
the order of "I know it's there, but I'm not going to use it all the
same" 8-)

Now my box behaves much more reasonably... I'll just have to beat harder
on it and see what happens.

Thank for the help,
- --rafal

- ----
Rafal Boni                                              rafal.boni@eDial.com
 PGP key C7D3024C, print EA49 160D F5E4 C46A 9E91  524E 11E0 7133 C7D3 024C
    Need to get a hold of me?  http://800.edial.com/rafal.boni@eDial.com

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.0 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE6TQgOEeBxM8fTAkwRArCFAKDVrzaWxGtRFR0pbyNwvIF20bOSiwCfdhg9
wK1ZAhaCfK5qcrQezDECiK4=
=9x6E
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Message-Id: <200304130317.h3D3HprZ021939@turing-police.cc.vt.edu>
Subject: Re: 2.5.67-mm2 
In-Reply-To: Your message of "Sun, 13 Apr 2003 03:55:29 +0200."
             <1050198928.597.6.camel@teapot.felipe-alfaro.com>
From: Valdis.Kletnieks@vt.edu
References: <20030412180852.77b6c5e8.akpm@digeo.com>
            <1050198928.597.6.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-1394136846P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sat, 12 Apr 2003 23:17:42 -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: Andrew Morton <akpm@digeo.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==_Exmh_-1394136846P
Content-Type: text/plain; charset=us-ascii

On Sun, 13 Apr 2003 03:55:29 +0200, Felipe Alfaro Solana said:

> Any patches for CardBus/PCMCIA support? It's broken for me since
> 2.5.66-mm2 (it works with 2.5.66-mm1) probably due to PCI changes or the
> new PCMCIA state machine: if I boot my machine with my 3Com CardBus NIC
> plugged in, the kernel deadlocks while checking the sockets, but it
> works when booting with the card unplugged, and then plugging it back
> once the system is stable (for example, init 1).

Also seeing this with a Xircom card under vanilla 2.5.67.

lspci reports this card as:

03:00.0 Ethernet controller: Xircom Cardbus Ethernet 10/100 (rev 03)
03:00.1 Serial controller: Xircom Cardbus Ethernet + 56k Modem (rev 03)

Russel King posted an analysis back on April 1, which indicated he knew
about the problem, understood it, and was working on it.


--==_Exmh_-1394136846P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQE+mNbVcC3lWbTT17ARAusmAKD8gvTxjgQBWOiK8m2vFeNgq1WyQACeP9FN
TT0oNQcSp3IMtjZKUvMUZ54=
=HZZf
-----END PGP SIGNATURE-----

--==_Exmh_-1394136846P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

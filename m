Date: Thu, 14 Sep 2000 18:08:25 +0200
From: Wichert Akkerman <wichert@soil.nl>
Subject: Re: Running out of memory in 1 easy step
Message-ID: <20000914180825.B19822@liacs.nl>
References: <20000914145904.B18741@liacs.nl> <20000914175633.A7675@fred.muc.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
In-Reply-To: <20000914175633.A7675@fred.muc.de>; from ak@muc.de on Thu, Sep 14, 2000 at 05:56:33PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-mm@kvack.org, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Previously Andi Kleen wrote:
> There is a hardwired limit of 1024 vmas/process. This is to avoid denial
> of service attacks with attackers using up all memory with vmas.

That's trivial to circumvent using multiple processes or even threads which
makes it a useless and possibly damaging protection imho..

Wichert.

--=20
  _________________________________________________________________
 / Generally uninteresting signature - ignore at your convenience  \
| wichert@liacs.nl                    http://www.liacs.nl/~wichert/ |
| 1024D/2FA3BC2D 576E 100B 518D 2F16 36B0  2805 3CB8 9250 2FA3 BC2D |


--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: 2.6.3ia

iQB1AwUBOcD3+ajZR/ntlUftAQGVzwL/eeBQkPtLb04+hRtqd8hM5/KvuHxeJC5A
+fEVaeLHj6Y51VlCoyE7jMcvtyRf9G6Dmfp7VdlmyP3X+DPgyR3/6BT1PFn0QcWy
gpV4bs/586DkCKJ3DAq/EQ/nUWSG817q
=QzoJ
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

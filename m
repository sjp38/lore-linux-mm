Date: Wed, 27 Nov 2002 22:19:13 +0100
From: Rasmus Andersen <rasmus@jaquet.dk>
Subject: Re: 2.5.49-mm2
Message-ID: <20021127221913.A9015@jaquet.dk>
References: <3DE48C4A.98979F0C@digeo.com> <20021127210153.A8411@jaquet.dk> <3DE526FC.3D78DB54@digeo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="pWyiEgJYm5f9v55/"
Content-Disposition: inline
In-Reply-To: <3DE526FC.3D78DB54@digeo.com>; from akpm@digeo.com on Wed, Nov 27, 2002 at 12:11:40PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 27, 2002 at 12:11:40PM -0800, Andrew Morton wrote:
> > (I did not copy the rest but can reproduce at will.)
>=20
> Please do.  And tell how you're making it happen.

Hand copied. Sorry, but I am not able to get a ksymoops
running on my system to decode this so raw oops follows.=20
I have put the System.map at www.jaquet.dk/kernel/System.map-2.5.49-mm2.
I hope that helps some.


Printing eip:
 4008c90
*pde =3D 06e73067
*pte =3D 071c8065
Oops: 0007
CPU: 0
EIP: 0023:[<40008c90>] Not tained
EFLAGS: 00010202
EIP is at 0x40008c90
eax: 0000003d  ebx: 4001274c  ecx: 401c2600  edx: 400134f0
ds: 002b   es: 002b   ss: 002b

Process ntpd (pid: 220, threadinfo=3Dc6e64000 task=3Dc7a9a0c0)
 <0> Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing


> Does it go away if you turn off preemption?

It does.

Regards,
  Rasmus

--pWyiEgJYm5f9v55/
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.0 (GNU/Linux)

iD8DBQE95TbRlZJASZ6eJs4RAlSQAJwKD7wBar+f1hVfuBv/MA2YVNZDTACeOEuo
zVAYNoJlakLirz+yLdE0dQw=
=ovD/
-----END PGP SIGNATURE-----

--pWyiEgJYm5f9v55/--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

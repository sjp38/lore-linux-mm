Date: Sat, 2 Aug 2003 22:38:51 -0700
Subject: Re: 2.6.0-test2-mm3
Message-ID: <20030803053851.GB25076@triplehelix.org>
References: <20030802152202.7d5a6ad1.akpm@osdl.org> <Pine.LNX.4.53.0308030106380.3473@montezuma.mastecende.com> <20030802222839.1904a247.akpm@osdl.org> <Pine.LNX.4.53.0308030118580.3473@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.53.0308030118580.3473@montezuma.mastecende.com>
From: Joshua Kwan <joshk@triplehelix.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 03, 2003 at 01:22:51AM -0400, Zwane Mwaikambo wrote:
> > > It works now by disabling CONFIG_MOUSE_PS2_SYNAPTICS
> > >=20
> >=20
> > err, that's a bug isn't it?
>=20
> I've had a hard time following the saga behind the synaptics code. I know=
=20
> there is some external thing you have to download but never got round to=
=20
> doing it. I'll give that a go now too with CONFIG_MOUSE_PS2_SYNAPTICS.=20
> Colour me lazy...

I really don't understand the point behind the synaptics code. I would
have imagined it to be an extension to the generic PS/2 code that would
finally allow me to use my 'scroll buttons' on my trackpad, but it has
caused nothing but problems. and I'm also kind of a console jockey so I
really need GPM working, which is why i'm always booting with
psmouse_noext these days...

-Josh

--=20
Using words to describe magic is like using a screwdriver to cut roast beef.
		-- Tom Robbins

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/LJ/rT2bz5yevw+4RAtgUAKDP4NRdOSb3TkB3pcC2h7wyqg7UlgCeOqGB
4hYbyWJtIFf/E3Pt/xfz5TU=
=d1V8
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

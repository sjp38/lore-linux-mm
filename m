Date: Wed, 15 Sep 2004 15:39:39 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
Message-ID: <20040915133939.GC30530@devserv.devel.redhat.com>
References: <413AA7B2.4000907@yahoo.com.au> <20040904230210.03fe3c11.davem@davemloft.net> <413AAF49.5070600@yahoo.com.au> <413AE6E7.5070103@yahoo.com.au> <Pine.LNX.4.58.0409051021290.2331@ppc970.osdl.org> <1094405830.2809.8.camel@laptop.fenrus.com> <Pine.LNX.4.58.0409051051120.2331@ppc970.osdl.org> <20040915132712.GA6158@wohnheim.fh-wedel.de> <20040915132904.GA30530@devserv.devel.redhat.com> <20040915133408.GB6158@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TiqCXmo5T1hvSQQg"
Content-Disposition: inline
In-Reply-To: <20040915133408.GB6158@wohnheim.fh-wedel.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, "David S. Miller" <davem@davemloft.net>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--TiqCXmo5T1hvSQQg
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 15, 2004 at 03:34:08PM +0200, J=F6rn Engel wrote:
> On Wed, 15 September 2004 15:29:04 +0200, Arjan van de Ven wrote:
> >=20
> > if you haven't pinned those pages then you have lost already.
>=20
> Bug reports say otherwise.  Could you explain "pinning" to a newbie
> like me?

if your page is made unfreeable for the vm, for example by virtue of not
being on the LRU or having an elevated count or.. or .. then such a page is
pinned.

if your page is freeable byt he VM and your device is dmaing from/to it you
have a really bad bug

--TiqCXmo5T1hvSQQg
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBSEYaxULwo51rQBIRAjYbAJ4iqRw0AGZZgzTrAuIrVvEp1I0DxgCfaAoL
nwv+i9R8Z4LFeBRYQaBREH8=
=7Fid
-----END PGP SIGNATURE-----

--TiqCXmo5T1hvSQQg--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

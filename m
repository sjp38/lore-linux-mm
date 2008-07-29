Date: Tue, 29 Jul 2008 10:06:18 +1000
From: Alex Samad <alex@samad.com.au>
Subject: Re: page swap allocation error/failure in 2.6.25
Message-ID: <20080729000618.GE1747@samad.com.au>
References: <20080725072015.GA17688@samad.com.au> <1216971601.7257.345.camel@twins> <20080727060701.GA7157@samad.com.au> <1217239487.6331.24.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JYK4vJDZwFMowpUq"
Content-Disposition: inline
In-Reply-To: <1217239487.6331.24.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 28, 2008 at 12:04:47PM +0200, Peter Zijlstra wrote:
> On Sun, 2008-07-27 at 16:07 +1000, Alex Samad wrote:
> > On Fri, Jul 25, 2008 at 09:40:01AM +0200, Peter Zijlstra wrote:
> > > On Fri, 2008-07-25 at 17:20 +1000, Alex Samad wrote:
> > > > Hi
> >=20
> > [snip]
> >=20
> > >=20
> > >=20
> > > Its harmless if it happens sporadically.=20
> > >=20
> > > Atomic order 2 allocations are just bound to go wrong under pressure.
> > can you point me to any doco that explains this ?
>=20
> An order 2 allocation means allocating 1<<2 or 4 physically contiguous
> pages. Atomic allocation means not being able to sleep.
>=20
> Now if the free page lists don't have any order 2 pages available due to
> fragmentation there is currently nothing we can do about it.

Strange cause I don't normal have a high swap usage, I have 2G ram and
2G swap space. There is not that much memory being used squid, apache is
about it.

>=20
> I've been meaning to try and play with 'atomic' page migration to try
> and assemble a higher order page on demand with something like memory
> compaction.
>=20
> But its never managed to get high enough on the todo list..
>=20
>=20

--=20
"I looked the man in the eye. I found him to be very straightforward and tr=
ustworthy... I was able to get a sense of his soul."

	- George W. Bush
06/16/2001
after meeting Russian President Vladimir Putin

--JYK4vJDZwFMowpUq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiOXvoACgkQkZz88chpJ2MImQCgvjaJnBndpImB/JdJyxT2jyJW
XoQAn1IyGLnIuZn/uWjJTOaHhTl6cgZv
=GP6O
-----END PGP SIGNATURE-----

--JYK4vJDZwFMowpUq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

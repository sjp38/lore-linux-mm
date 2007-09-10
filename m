Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709101225350.24735@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <20070905114242.GA19938@wotan.suse.de>
	 <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
	 <20070905121937.GA9246@wotan.suse.de>
	 <Pine.LNX.4.64.0709101225350.24735@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vZgxFaUnD3pN0yohNHoy"
Date: Mon, 10 Sep 2007 21:37:11 +0200
Message-Id: <1189453031.21778.28.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

--=-vZgxFaUnD3pN0yohNHoy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-09-10 at 12:29 -0700, Christoph Lameter wrote:
> On Wed, 5 Sep 2007, Nick Piggin wrote:
>=20
> > Implementation issues aside, the problem is there and I would like to
> > see it fixed regardless if some/most/or all users in practice don't
> > hit it.
>=20
> I am all for fixing the problem but the solution can be much simpler and=20
> more universal. F.e. the amount of tcp data in flight may be controlled=20
> via some limit so that other subsystems can continue to function even if=20
> we are overwhelmed by network traffic.

With swap over network you need not only protect other subsystems from
networking, but you also have to guarantee networking will in some form
stay functional, otherwise you'll never receive the writeout completion.

>  Peter's approach establishes the=20
> limit by failing PF_MEMALLOC allocations.=20

I'm not failing PF_MEMALLOC allocations. I'm more stringent in failing !
PF_MEMALLOC allocations.

> If that occurs then other=20
> subsystems (like the disk, or even fork/exec or memory management=20
> allocation) will no longer operate since their allocations no longer=20
> succeed which will make the system even more fragile and may lead to=20
> subsequent failures.

Failing allocations should never be a stability problem, we have the
fault-injection framework which allows allocations to fail randomly -
this should never crash the kernel - if it does its a BUG.

--=-vZgxFaUnD3pN0yohNHoy
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG5ZznXA2jU0ANEf4RArjEAJ9f1xNJBfypM0uf/kA40IPOIyGD2QCgi19D
B8toeZ/ycbmdXVVKUQ7HxOI=
=xOmX
-----END PGP SIGNATURE-----

--=-vZgxFaUnD3pN0yohNHoy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

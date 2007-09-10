Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709101238510.24941@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <20070905114242.GA19938@wotan.suse.de>
	 <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
	 <20070905121937.GA9246@wotan.suse.de>
	 <Pine.LNX.4.64.0709101225350.24735@schroedinger.engr.sgi.com>
	 <1189453031.21778.28.camel@twins>
	 <Pine.LNX.4.64.0709101238510.24941@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+ErkCB7gZoc7iCZsR0jC"
Date: Mon, 10 Sep 2007 21:55:22 +0200
Message-Id: <1189454122.21778.47.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

--=-+ErkCB7gZoc7iCZsR0jC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-09-10 at 12:41 -0700, Christoph Lameter wrote:
> On Mon, 10 Sep 2007, Peter Zijlstra wrote:
>=20
> > >  Peter's approach establishes the=20
> > > limit by failing PF_MEMALLOC allocations.=20
> >=20
> > I'm not failing PF_MEMALLOC allocations. I'm more stringent in failing =
!
> > PF_MEMALLOC allocations.
>=20
> Right you are failing other allocations.
>=20
> > > If that occurs then other=20
> > > subsystems (like the disk, or even fork/exec or memory management=20
> > > allocation) will no longer operate since their allocations no longer=20
> > > succeed which will make the system even more fragile and may lead to=20
> > > subsequent failures.
> >=20
> > Failing allocations should never be a stability problem, we have the
> > fault-injection framework which allows allocations to fail randomly -
> > this should never crash the kernel - if it does its a BUG.
>=20
> Allright maybe you can get the kernel to be stable in the face of having=20
> no memory and debug all the fallback paths in the kernel when an OOM=20
> condition occurs.
>=20
> But system calls will fail? Like fork/exec? etc? There may be daemons=20
> running that are essential for the system to survive and that cannot=20
> easily take an OOM condition? Various reclaim paths also need memory and=20
> if the allocation fails then reclaim cannot continue.

I'm not making any of these paths significantly more likely to occur
than they already are. Lots and lots of users run swap heavy loads day
in day out - they don't get funny systems (well sometimes they do, and
theoretically we can easily run out of the PF_MEMALLOC reserves -
HOWEVER in practise it seems to work quite reliably).

--=-+ErkCB7gZoc7iCZsR0jC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG5aEqXA2jU0ANEf4RAgz2AJ9QTgnvZ6qXTF8CEGZqdkuVTos1VACeMRjc
Trl22aYJimTFPCeTebYbwHc=
=Y/Tk
-----END PGP SIGNATURE-----

--=-+ErkCB7gZoc7iCZsR0jC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

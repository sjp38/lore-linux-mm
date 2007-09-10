Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709101315020.25407@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>
	 <200709050220.53801.phillips@phunq.net>
	 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
	 <20070905114242.GA19938@wotan.suse.de>
	 <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
	 <20070905121937.GA9246@wotan.suse.de>
	 <Pine.LNX.4.64.0709101225350.24735@schroedinger.engr.sgi.com>
	 <1189453031.21778.28.camel@twins>
	 <Pine.LNX.4.64.0709101238510.24941@schroedinger.engr.sgi.com>
	 <1189454122.21778.47.camel@twins>
	 <Pine.LNX.4.64.0709101315020.25407@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-HZnqvUZz3witRkNaYttG"
Date: Mon, 10 Sep 2007 22:48:01 +0200
Message-Id: <1189457281.21778.67.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

--=-HZnqvUZz3witRkNaYttG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-09-10 at 13:17 -0700, Christoph Lameter wrote:
> On Mon, 10 Sep 2007, Peter Zijlstra wrote:
>=20
> > > Allright maybe you can get the kernel to be stable in the face of hav=
ing=20
> > > no memory and debug all the fallback paths in the kernel when an OOM=20
> > > condition occurs.
> > >=20
> > > But system calls will fail? Like fork/exec? etc? There may be daemons=
=20
> > > running that are essential for the system to survive and that cannot=20
> > > easily take an OOM condition? Various reclaim paths also need memory =
and=20
> > > if the allocation fails then reclaim cannot continue.
> >=20
> > I'm not making any of these paths significantly more likely to occur
> > than they already are. Lots and lots of users run swap heavy loads day
> > in day out - they don't get funny systems (well sometimes they do, and
> > theoretically we can easily run out of the PF_MEMALLOC reserves -
> > HOWEVER in practise it seems to work quite reliably).
> >=20
>=20
> The patchset increases these failures significantly since there will be a=
=20
> longer time period where these allocations can fail.
>=20
> The swap loads are fine as long as we do not exhaust the reserve pools.

And I'm working hard to guarantee the additional logic does not exhaust
said pools by making it strictly bounded.

> IMHO the right solution is to throttle the networking layer to not do=20
> unbounded allocations.

Am I not doing exactly that?

>  You can likely do this by checking certain VM=20
> counters like SLAB_UNRECLAIMABLE. If need be we can add a new category of=
=20
> SLAB_TEMPORARY for temporary allocs and track these. If they get too larg=
e=20
> then throttle.

I'm utterly confused as to why you propose all these heuristics when I
have a perfectly good solution that is exact.

--=-HZnqvUZz3witRkNaYttG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG5a2BXA2jU0ANEf4RAvIKAJ0YhDX8C+sdtO0ALDZN5Cgpp3C3RQCgilAJ
p9vgDMeT+38YaVyDBNoHCVc=
=9x+J
-----END PGP SIGNATURE-----

--=-HZnqvUZz3witRkNaYttG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

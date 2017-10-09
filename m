From: Mark Brown <broonie@kernel.org>
Subject: Re: mmotm 2017-10-03-17-08 uploaded
Date: Mon, 9 Oct 2017 21:37:10 +0100
Message-ID: <20171009203710.6ick6l3kpmqhiq23@sirena.co.uk>
References: <59d4268c.FlFtK0Mqe7TSSBd5%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="w4452otkpsr4eyvu"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <59d4268c.FlFtK0Mqe7TSSBd5%akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz
List-Id: linux-mm.kvack.org


--w4452otkpsr4eyvu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 03, 2017 at 05:08:44PM -0700, akpm@linux-foundation.org wrote:

> You will need quilt to apply these patches to the latest Linus release (4.x
> or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series

I'm getting several merge errors importing the current tree but I have
to confess I don't really understand what the conflicts were as I don't
100% follow what the script is doing with the imports, it's getting late
and there's some use of old -next trees which is confusing me.  All the
merge resolutions appear to come out as null diffs so I think everything
is fine but please check when I push today's -next release shortly.

--w4452otkpsr4eyvu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnb3fYACgkQJNaLcl1U
h9A4AAf+PZYxqIql06lrhRaUhqUH7kv1FYkx+gi0OMLOuZA52TSP2qltkn++f4BL
oclkT/YRZG4PIQAxp+mS68QuqrHIghABP/TFzVCogCYlo7x9MjAuYFWDlG/nPuTg
E6WrmlDF+c806HimAYmzXX0Ie7AVcpStpjHOU5PNxAPtHBiBgQmlbwrqndMNOpVk
HdlFNATQSd8vMNbAoqViezIk/H/dqjHHjE14cSi3VJcGhEyjsWsONX9k3G7qeqPQ
TkNi7wolp+1dheCIw00lMWY+fs2QKrGavlP3DmsSno0mpKGEKoIdvjRb3OgCn/io
6n6NEusAALcr+gFTy6GbMQdDgAcYXA==
=OBVA
-----END PGP SIGNATURE-----

--w4452otkpsr4eyvu--

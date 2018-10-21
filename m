Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Sun, 21 Oct 2018 14:37:45 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 32-bit PTI with THP = userspace corruption
Message-ID: <20181021123745.GA26042@amd>
References: <alpine.LRH.2.21.1808301639570.15669@math.ut.ee>
 <20180830205527.dmemjwxfbwvkdzk2@suse.de>
 <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
 <20180831070722.wnulbbmillxkw7ke@suse.de>
 <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
 <20180911114927.gikd3uf3otxn2ekq@suse.de>
 <alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
 <20180911121128.ikwptix6e4slvpt2@suse.de>
 <20180918140030.248afa21@alans-desktop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Content-Disposition: inline
In-Reply-To: <20180918140030.248afa21@alans-desktop>
Sender: linux-kernel-owner@vger.kernel.org
To: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Cc: Joerg Roedel <jroedel@suse.de>, Meelis Roos <mroos@linux.ee>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue 2018-09-18 14:00:30, Alan Cox wrote:
> On Tue, 11 Sep 2018 14:12:22 +0200
> Joerg Roedel <jroedel@suse.de> wrote:
>=20
> > On Tue, Sep 11, 2018 at 02:58:10PM +0300, Meelis Roos wrote:
> > > The machines where I have PAE off are the ones that have less memory.=
=20
> > > PAE is off just for performance reasons, not lack of PAE. PAE should =
be=20
> > > present on all of my affected machines anyway and current distributio=
ns=20
> > > seem to mostly assume 686 and PAE anyway for 32-bit systems. =20
> >=20
> > Right, most distributions don't even provide a non-PAE kernel for their
> > users anymore.
> >=20
> > How big is the performance impact of using PAE over legacy paging?
>=20
> On what system. In the days of the original 36bit PAE Xeons it was around
> 10% when we measured it at Red Hat, but that was long ago and as you go
> newer it really ought to be vanishingly small.
>=20
> There are pretty much no machines that don't support PAE and are still
> even vaguely able to boot a modern Linux kernel. The oddity is the
> Pentium-M but most distros shipped a hack to use PAE on the Pentium M
> anyway as it seems to work fine.

I do have some AMD Geode here, in form of subnotebook. Definitely
newer then Pentium Ms, but no PAE...

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvMcxkACgkQMOfwapXb+vJ6pgCgu3iDvOnkmr4HLzuB2U2AzpSE
uwgAoKVSZZZk13M9JhHUdFhHkzV6VtfE
=ssuM
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--

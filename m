Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 23 Oct 2018 11:11:27 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Not-so-old machines without PAE was Re: 32-bit PTI with THP =
 userspace corruption
Message-ID: <20181023091127.GA9843@amd>
References: <alpine.LRH.2.21.1808310711380.17865@math.ut.ee>
 <20180831070722.wnulbbmillxkw7ke@suse.de>
 <alpine.DEB.2.21.1809081223450.1402@nanos.tec.linutronix.de>
 <20180911114927.gikd3uf3otxn2ekq@suse.de>
 <alpine.LRH.2.21.1809111454100.29433@math.ut.ee>
 <20180911121128.ikwptix6e4slvpt2@suse.de>
 <20180918140030.248afa21@alans-desktop>
 <20181021123745.GA26042@amd>
 <20181022075642.icowfdg3y5wcam63@suse.de>
 <20181022194817.148796e6@alans-desktop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PEIAKu/WMn1b1Hv9"
Content-Disposition: inline
In-Reply-To: <20181022194817.148796e6@alans-desktop>
Sender: linux-kernel-owner@vger.kernel.org
To: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Cc: Joerg Roedel <jroedel@suse.de>, Meelis Roos <mroos@linux.ee>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


--PEIAKu/WMn1b1Hv9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2018-10-22 19:48:17, Alan Cox wrote:
> On Mon, 22 Oct 2018 09:56:42 +0200
> Joerg Roedel <jroedel@suse.de> wrote:
>=20
> > On Sun, Oct 21, 2018 at 02:37:45PM +0200, Pavel Machek wrote:
> > > On Tue 2018-09-18 14:00:30, Alan Cox wrote: =20
> > > > There are pretty much no machines that don't support PAE and are st=
ill
> > > > even vaguely able to boot a modern Linux kernel. The oddity is the
> > > > Pentium-M but most distros shipped a hack to use PAE on the Pentium=
 M
> > > > anyway as it seems to work fine. =20
> > >=20
> > > I do have some AMD Geode here, in form of subnotebook. Definitely
> > > newer then Pentium Ms, but no PAE... =20
> >=20
> > Are the AMD Geode chips affected by Meltdown?
>=20
> Geode for AMD was just a marketing name.
>=20
> The AMD athlon labelled as 'Geode' will behave like any other Athlon but
> I've not seen anyone successfully implement Meltdown on the Athlon so it's
> probably ok.=20
>=20
> The earlier NatSemi ones are not AFAIK vulnerable to either. The later
> ones might do Spectre (they have branch prediction which is disabled on
> the earlier ones) but quite possibly not enough to be attacked usefully -
> and you can turn it off anyway if you care.
>=20
> And I doubt your subnotebook can usefully run modern Linux since the
> memory limit on most Geode was about 64MB.

Well, let me see. The machine is not too useful because of dead
battery, but I don't believe RAM would be a problem. It has 512MB or
more, IIRC. Missing PAE is, and missing instructions are. And horrible
keyboard and bad driver support from Linux. And... Ouch and fact that
I use its power supply to power something else.

It looks similar to this:
https://hexus.net/tech/news/laptop/13994-kohjinsha-launches-impressive-subn=
otebook-twist/
(but has no touchscreen).

Bios is "built 03/02/2007".

CPU is "AuthenticAMD" family 5 model 10, "Geode(TM) Integrated Processor
by AMD PCS". 500 MHz, flags "fpu de pse tsc msr cx8 sep pge cmov
clflush mmx mmxext 3dnowext 3dnow". 512MB RAM.

This is not a suitable compile server, but still could work as a
subnotebook given right software...


									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--PEIAKu/WMn1b1Hv9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlvO5b8ACgkQMOfwapXb+vIqlwCgruwFLlA3MLQtzHmSt4hS12oG
MlMAoL5wASCKq9SjjCtBjlpVoz1vx2S4
=o3Dr
-----END PGP SIGNATURE-----

--PEIAKu/WMn1b1Hv9--

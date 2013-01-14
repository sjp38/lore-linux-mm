Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 554A46B006E
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 23:03:21 -0500 (EST)
Date: Mon, 14 Jan 2013 15:03:14 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2013-01-11-15-47 uploaded (x86 asm-offsets broken)
Message-Id: <20130114150314.d48d73b145d66049ba4a169d@canb.auug.org.au>
In-Reply-To: <1357957789.2168.11.camel@joe-AO722>
References: <20130111234813.170A620004E@hpza10.eem.corp.google.com>
	<50F0BFAA.10902@infradead.org>
	<20130112131713.749566c8d374cd77b1f2885e@canb.auug.org.au>
	<1357957789.2168.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__14_Jan_2013_15_03_14_+1100_HxFuEtG72tXyZwq3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

--Signature=_Mon__14_Jan_2013_15_03_14_+1100_HxFuEtG72tXyZwq3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Joe, Andrew,

On Fri, 11 Jan 2013 18:29:49 -0800 Joe Perches <joe@perches.com> wrote:
>
> On Sat, 2013-01-12 at 13:17 +1100, Stephen Rothwell wrote:
> > On Fri, 11 Jan 2013 17:43:06 -0800 Randy Dunlap <rdunlap@infradead.org>=
 wrote:
> > >
> > > b0rked.
> > >=20
> > > Some (randconfig?) causes this set of errors:
>=20
> I guess that's when CONFIG_HZ is not an even divisor of 1000.
> I suppose this needs to be worked on a bit more.

I have dropped "jiffies conversions: Use compile time constants when
possible" from the copy of mmotm in linux-next.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__14_Jan_2013_15_03_14_+1100_HxFuEtG72tXyZwq3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ84OCAAoJEECxmPOUX5FE8zEQAIHS01Uyu+5pGl4FCpSq0fQa
4Keeaf6ewLpbM2peUIvj06RkLFm8pcE6roYyF/Es5NgA6ljwgjIG4w3Fkp3le4nb
mGEtfemHfbqjrwN6aekKU5/yQGBCKBdA9aPpgf5geKiNg7Ea1uJHIB3HeGGld+7l
VmQEQ0Vjv0ri/EB6aDixQb8r2k8gBwz81PrkDlWc60auY2cniMYILw0fyWD71mrg
08iWcU/9Uec0pYDItD4DhqvCLaRzFSMrh4g0MXoBVr0QCrldSlD03j0NQGsrtOJt
SllovVAzMH8TVnwHxP7gKuT48BanVtGqEIrfp8kEHlJUM/T1W/wZjSbgl6jbxJDG
OT5lgwcOpdaEF4Ts6FtFOsUt6ysr94Z6bQ8t3NZI6+7dhezT+pL6wMxJDAmF4YzJ
BzzCW2KxxOkHWYkRRMeYdkvQfWPlvOhLibmPpNb3GqHNqsG8Hu0o+CkEg5gM813N
XEqb2eEx0NfGkDTfyMtaH3Oicas+encV82shth8GdIem1Uuq1UaXHTo/Wzx30Lrw
Lh5qQYP/3CYEppgocdolsPb4FEmPpVi7YL3iXWVQqgoaziRyw00A0JAi73FQ3UBv
mZ5DFjanhphTiPLsUFOCPmQusT4KIoVKNDcmsBUNowuqJ2Tvb2rQ2x0hysqGPGcQ
1woVFcg9TjW03yDcxSxq
=Eeog
-----END PGP SIGNATURE-----

--Signature=_Mon__14_Jan_2013_15_03_14_+1100_HxFuEtG72tXyZwq3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

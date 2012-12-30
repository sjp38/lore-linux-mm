Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 03F306B006C
	for <linux-mm@kvack.org>; Sun, 30 Dec 2012 05:38:00 -0500 (EST)
Date: Sun, 30 Dec 2012 12:38:50 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: 3.8-rc1 build failure with MIPS/SPARSEMEM
Message-ID: <20121230103850.GA5424@otc-wbsnb-06>
References: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi>
 <20121226003434.GA27760@otc-wbsnb-06>
 <20121227121607.GA7097@blackmetal.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <20121227121607.GA7097@blackmetal.musicnaut.iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, Aaro Koskinen <aaro.koskinen@iki.fi>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 27, 2012 at 02:16:07PM +0200, Aaro Koskinen wrote:
> Hi,
>=20
> On Wed, Dec 26, 2012 at 02:34:35AM +0200, Kirill A. Shutemov wrote:
> > On MIPS if SPARSEMEM is enabled we've got this:
> >=20
> > In file included from /home/kas/git/public/linux/arch/mips/include/asm/=
pgtable.h:552,
> >                  from include/linux/mm.h:44,
> >                  from arch/mips/kernel/asm-offsets.c:14:
> > include/asm-generic/pgtable.h: In function =E2=80=98my_zero_pfn=E2=80=
=99:
> > include/asm-generic/pgtable.h:466: error: implicit declaration of funct=
ion =E2=80=98page_to_section=E2=80=99
> > In file included from arch/mips/kernel/asm-offsets.c:14:
> > include/linux/mm.h: At top level:
> > include/linux/mm.h:738: error: conflicting types for =E2=80=98page_to_s=
ection=E2=80=99
> > include/asm-generic/pgtable.h:466: note: previous implicit declaration =
of =E2=80=98page_to_section=E2=80=99 was here
> >=20
> > Due header files inter-dependencies, the only way I see to fix it is
> > convert my_zero_pfn() for __HAVE_COLOR_ZERO_PAGE to macros.
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>=20
> Thanks, this works.
>=20
> Tested-by: Aaro Koskinen <aaro.koskinen@iki.fi>

Andrew, could you take the patch?

--=20
 Kirill A. Shutemov

--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ4Bm5AAoJEAd+omnVudOMz1oP/3Gv20OjCZOhdYhdsufNiNDN
Hw5t2YwyzXVQ+HtHpqQuMXzdbHJYDWGALwvoyw1QMBxYkD8hVpc6bD7DpL23QHqv
JhV3luv30NrXIFaIhnu2ZPjNST43jVCI1SOrg35hTqCGehYtQIYuIWvDytXNlJtu
6chzAon5KgGS1fY60G7t0uL8CyLzywDZ7Gs0Y5S3TizR0Z/J5kk3R3uHN6oRsN3Y
WWKKebJgLtzq6cWoVjJhFvB+HqAHK7I4+6hpcE7FvC0phjJubCcnLDQ8g7O2XKBY
jOTOVZt4SbOuzsBYvNzVPIkxOW4M9pfy4NUw9MWPR/ilJGWlM6k2dJ+9Zum2fKLE
dJ3J1McnfSgf5HUIR7icPxeklCGUsWl2qjqINP7k0j4bYmlHLdYKV1N0FPdSTb/F
f0nuzbHB1DbvID9OXgyzkrznTdZ7vx67RJSLkR6tFzeaKZJbqlVcGc+l9B+EA6o1
E8VHlXWpyH7kncIHXUOgoY93LESWAMF6/lLjCUZqVIxMZV9/T+bpkcAAuambS10Q
tswy3L5I6oMvkfXviSjUfa7HFxfhkvGPoocDdStS4v8SAlK/aM6K12U/Vlr/Svif
5lfavj8P9S+R0ECyn+4wdzP71zRkmB4MP+eJdG8jSnos0zpZq21nntKCeD+EcWEC
/3r3MPDCqj+vz32O6xke
=VVis
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

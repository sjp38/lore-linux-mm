Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EA4866B0031
	for <linux-mm@kvack.org>; Sun, 17 Nov 2013 22:04:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1104081pad.28
        for <linux-mm@kvack.org>; Sun, 17 Nov 2013 19:04:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.197])
        by mx.google.com with SMTP id ei3si8384688pbc.320.2013.11.17.19.04.33
        for <linux-mm@kvack.org>;
        Sun, 17 Nov 2013 19:04:34 -0800 (PST)
Date: Mon, 18 Nov 2013 14:04:17 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 2/2] mm: create a separate slab for page->ptl allocation
Message-Id: <20131118140417.9e8aee3f72a006ec3c6c6000@canb.auug.org.au>
In-Reply-To: <CAMuHMdV33zBfsztXGsSv5YO+r4c2Fxh+0tH7togtS7EjdhDXeA@mail.gmail.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1383833644-27091-2-git-send-email-kirill.shutemov@linux.intel.com>
	<CAMuHMdV33zBfsztXGsSv5YO+r4c2Fxh+0tH7togtS7EjdhDXeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__18_Nov_2013_14_04_17_+1100_SgXCLQNUyQi/GN2z"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

--Signature=_Mon__18_Nov_2013_14_04_17_+1100_SgXCLQNUyQi/GN2z
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Geert,

On Sat, 16 Nov 2013 21:43:32 +0100 Geert Uytterhoeven <geert@linux-m68k.org=
> wrote:
>
> On Thu, Nov 7, 2013 at 3:14 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
>=20
> > +static inline void pgtable_init(void)
> > +{
> > +       ptlock_cache_init();
> > +       pgtable_cache_init();
> > +}
>=20
> sparc64defconfig:
>=20
> include/linux/mm.h:1391:2: error: implicit declaration of function
> 'pgtable_cache_init' [-Werror=3Dimplicit-function-declaration]
> arch/sparc/include/asm/pgtable_64.h:978:13: error: conflicting types
> for 'pgtable_cache_init' [-Werror]
>=20
> http://kisskb.ellerman.id.au/kisskb/buildresult/10040274/
>=20
> Has this been in -next?

No, it hasn't :-(

> Probably it needs <asm/pgtable.h>.

Actually it is because on sparc64, asm/tlbflush_64.h includes linux/mm.h
(and asm/pgtable.h -> asm/pgtable_64.h -> asm/tlbflush.h ->
asm/tlbflush_64.h)

(see my other error report and I have reverted that commit from
linux-next today.)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__18_Nov_2013_14_04_17_+1100_SgXCLQNUyQi/GN2z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSiYO2AAoJEMDTa8Ir7ZwV278P/1p+/c1iOiRhWrrIlqWtunMk
hSeZT44IbzfXm9QBx822E/AzmBFiEIhb1tq4f0Ngi1BVFkUr3bSPBrRGxf3LMrrd
cnLdN4KEj4jb4fEl6scy9GA9NjsLiEBPEf+olgwNFXfTjprtq2TQriS1iuN8Hvde
IBT8hns8FbRyaH2e9+uR7Os3MCNUa8cGvIsvIlqOj1xDx/Ro9yW8Si24k5Pn38tm
3Rr4zEQVZgvqcT3slX3B54ADcL2unvKf51liXIcgyhRi9qtHocIMnDHjxQg12n16
JcNVNv7hVz4NWuIvHMxznX8NOUDBjQoiXyC/bIuNfmJuCFJ+OcvrmVEifIbAmU9h
475bYVy0qzBCqz1V5HPzL0UIlE8MJ7dlSbiK3fmHgKJ2hkFKV4lYHbenxIq1Mz4/
S5DxTKXIRdH0vUmuJgAgx44p0yvZGezbTcVXmjL4BXtsRUXDKjmBu88bUbpBgCtj
ipZJE/LhgLRsvSrPmYn/wilMiuLOa70xoulO2bB5T0AqluF80/7R7AoYOvuqj5uJ
SGcyWkgbCvHNc0AFSq0blR+dRTD5XWdeqGmkDx30vP6LoDXrEHZXyPdYBmJg5fRN
zp+JmfcIKBqflCjksWtytgW+VtMP5Ndt4KhH4Z6Rm8sfKGA3stJm+w+bloC7K96i
5aWE1/l9CqUYV/2gTy5O
=Pqjh
-----END PGP SIGNATURE-----

--Signature=_Mon__18_Nov_2013_14_04_17_+1100_SgXCLQNUyQi/GN2z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

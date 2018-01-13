Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB5066B0038
	for <linux-mm@kvack.org>; Sat, 13 Jan 2018 00:59:42 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id h200so8841105itb.3
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 21:59:42 -0800 (PST)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id p189si14786796iod.57.2018.01.12.21.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 21:59:41 -0800 (PST)
Date: Fri, 12 Jan 2018 21:57:39 -0800
From: "W. Trevor King" <wking@tremily.us>
Subject: Re: [PATCH] security/Kconfig: Replace pagetable-isolation.txt
 reference with pti.txt
Message-ID: <20180113055739.GC19082@valgrind.us>
References: <9b21ce8f-625c-6915-654b-42334cf38e99@linux.intel.com>
 <3009cc8ccbddcd897ec1e0cb6dda524929de0d14.1515799398.git.wking@tremily.us>
 <68769b20-2be5-85b7-f21c-cc9094de547c@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Content-Disposition: inline
In-Reply-To: <68769b20-2be5-85b7-f21c-cc9094de547c@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-security-module@vger.kernel.org, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 12, 2018 at 05:19:32PM -0800, Dave Hansen wrote:
> On 01/12/2018 03:24 PM, W. Trevor King wrote:
> >> If you're going to patch this, please send an update to -tip that
> >> corrects the filename.
> >=20
> > Here you go :).
>=20
> Feel free to add my Acked-by.  And please send to x86@kernel.org.
> They need to put this in after the addition of the documentation.

I've bounced my patch and your reply to x86@kernel.org (although your
reply may not go through, I'm not sure what Intel has setup for
SPF/DMARC/=E2=80=A6).

And this is a very small fix.  If it's easier to just have somebody
with commit access to the appropriate feeder repo file the patch
wherever it needs to go, that's fine with me too.

Cheers,
Trevor

--=20
This email may be signed or encrypted with GnuPG (http://www.gnupg.org).
For more information, see http://en.wikipedia.org/wiki/Pretty_Good_Privacy

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEpgNNa8H/zemHkt2gprXBz9Wld7YFAlpZn84ACgkQprXBz9Wl
d7ZDmA//S5DxfrZ2EeH81ZfnmR+ObX+j3dQWCMtsmbYG7mlbXcTuU6ZM0SXZPogM
nfEyUksK7OXrlYiAprVbpdAYeoJNZ0yKiDEQdAEdMq4vxYPvGbLlN1uEAbTJPT7I
J/iJ9J1qbxzjbi1FGIZf605A11Hc54l3YITYKaT5ylWo4Ws2NzM3WNF78MbE0zEI
SbgoR4kRlSPcJ0n6BIQqMTgAxP9sPZXIGeYe838/PJp4I8z919XSZk9bpiSjOFu9
6hQG41IB91TWwZpf9WZ56RBTelOJdKeP02IJGkGkq0fYfx5ytDgfK7ffY13/S2Is
ktGB+gic1j6ps1ZSY/s3V6fcKPpeKpQRov6VpAxnOwx3HBzA35QRXqYGsAMGhkEA
aC+uCIFR3zrvUm3gv91x+8wVDdWVNPRic5CBfrzfQzw6rMaOY2ypEc+MKNt9xq1x
197LgEWee8Te7N2pupOsgwhJHm82szkvxzy0TQ/mvkZ6m60QKMiWbj9/vmNs3wX1
L4Z67xWNCArqdxxlF9pfDF5p7bnMY9FNos6pkoZCW7hEp/OZHAixmVSdN585uBUD
NqFQlwx66yYRvpnJINaR5LLE1mDIxtJhq2YegQO1S4BZe2R3erxsmsAikn5oqyCa
C08gObw9yXzi2C+CkS01biP5TjEmaWi+RhGqWHD9jg22Wd9nokk=
=3YSW
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

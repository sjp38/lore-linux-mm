Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 527346B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:39:41 -0400 (EDT)
Date: Fri, 8 Jun 2012 11:39:30 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Message-Id: <20120608113930.cfce1835c119b15c16eabf7c@canb.auug.org.au>
In-Reply-To: <20120607180515.4afffc89.akpm@linux-foundation.org>
References: <20120608002451.GA821@redhat.com>
	<CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
	<20120607180515.4afffc89.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__8_Jun_2012_11_39_30_+1000_ooMGAY4SR7RaiGJh"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>

--Signature=_Fri__8_Jun_2012_11_39_30_+1000_ooMGAY4SR7RaiGJh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Thu, 7 Jun 2012 18:05:15 -0700 Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>
> It appears this is due to me fat-fingering conflict resolution last
> week.  That hunk is supposed to be in mm_release(), not mmput().   =20
>=20
> It's probably best to throw the patch away for now - we'll try again.

I have reverted that commit from linux-next and will remove it from the cop=
y of the akpm tree that I have.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__8_Jun_2012_11_39_30_+1000_ooMGAY4SR7RaiGJh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP0VfSAAoJEECxmPOUX5FE41YP/36GD09NRx99I75Vnm2BZ6K8
UWwQjdhJ1ETCLASU6RKTOoMO3Cc1xk85ww8/IJpySSDRN7GDIZLf2eIkG75QbyyV
UvEWZzHSRB11aKbJXjMEVJmN/hQb1euORX9tO2EUnoLYZTtKpK5JI/rdkiK2ZEt2
UxeXyHxSOsGJTiWQ28eF3ilNG2zmZ43Tyj2CWWWJuM9tL8uGufKMqfePKKqB332s
6hy2pFpijK+qgeBuJgy35ruK2MYr2bLyGJwc8nMevqxh+I9xd20yOLUTocC6FMOU
Kztnu/CulDp/zF2Qs/gcTQ7XEuIDrKsN4YHwdOWKF/P6u7jN/1PiArsDCZDR+h2F
lAzUWOH06yg+ZXc/fu/8NdA0Tmm6BH4PU1wIc3TZ3VtY18RbmXK3dmHz+5qSnSUi
OgXEHOTi3ydFclTotHiB6BZWsfqRUK+uR1crkqfHl4emBpq98wF1jyYXswmhdXAi
J5FEGnQV37zBmo8ps4in9YSeNoX7+2DGxG6hRAyHE6Z+GRdKXPoWk81KuEH8wouq
vYI71p294rR8EY4bzRo9sLAl5yB0ekc/Ca+NBWHA2LN7dVhzoshT37CzYj3oKsbI
U+P+EncxQLcfFFRvuBzp11A8n+kVySoqP8VM33wx2F469QVfcMHLOoewv9sEXMgc
Yvxtv/ALUytvQ9dbqg5G
=zd95
-----END PGP SIGNATURE-----

--Signature=_Fri__8_Jun_2012_11_39_30_+1000_ooMGAY4SR7RaiGJh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

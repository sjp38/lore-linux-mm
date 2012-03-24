Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 909FA6B00F9
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 07:12:44 -0400 (EDT)
Message-ID: <4F6DAC28.301@nod.at>
Date: Sat, 24 Mar 2012 12:12:40 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH 07/10] um: Should hold tasklist_lock while traversing
 processes
References: <20120324102609.GA28356@lizard> <20120324103030.GG29067@lizard>
In-Reply-To: <20120324103030.GG29067@lizard>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE41A5EA7F7A3D882738B89D5"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE41A5EA7F7A3D882738B89D5
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 24.03.2012 11:30, schrieb Anton Vorontsov:
> Traversing the tasks requires holding tasklist_lock, otherwise it
> is unsafe.
>=20
> p.s. However, I'm not sure that calling os_kill_ptraced_process()
> in the atomic context is correct. It seem to work, but please
> take a closer look.

os_kill_ptraced_process() calls a host function.
=46rom UML's point of view nothing sleeps, so this is fine.

Acked-by: Richard Weinberger <richard@nod.at>

Thanks,
//richard


--------------enigE41A5EA7F7A3D882738B89D5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPbawoAAoJEN9758yqZn9enHsH/04wJSPdhgma1hiCpbwhLKzT
jLaxk9Jl2lXj7n7ydXmtkkiYkO9QCi9syUAFKi5fV0HDyI4Yvo9ymPUOxAd569mQ
p8Jo3iUBrgDKMbUAHyK+xxawB0TsLynRQbNY1iaKhbjcR9ejqKddlDXlV40GI3k0
bU/Yk1umtUZhV9sT1ymTiHa/zAzRRhTa/AlOONRsLFWYGwtdYTm2vnDwPR0x18Zg
kNF0OKf1/4hFCNUHYpJ8F99PDMN/T5hyJ52iXUsqeg/eJS5rJopbtsTFUxf1Fh78
ksu1G6Xh5iWQVHQPDWcNrSN7t4oWbpb6OlsdojQYdOEXySuUtBVELMcjhwMCELU=
=bzOH
-----END PGP SIGNATURE-----

--------------enigE41A5EA7F7A3D882738B89D5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

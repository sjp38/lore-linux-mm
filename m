Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 92F6D6B00FA
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 07:12:30 -0400 (EDT)
Message-ID: <4F6DAC15.7040702@nod.at>
Date: Sat, 24 Mar 2012 12:12:21 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH 09/10] um: Properly check all process' threads for a live
 mm
References: <20120324102609.GA28356@lizard> <20120324103110.GI29067@lizard>
In-Reply-To: <20120324103110.GI29067@lizard>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig88EC09FADEB6B6709009C1CF"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Russell King <linux@arm.linux.org.uk>, Mike Frysinger <vapier@gentoo.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig88EC09FADEB6B6709009C1CF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 24.03.2012 11:31, schrieb Anton Vorontsov:
> kill_off_processes() might miss a valid process, this is because
> checking for process->mm is not enough. Process' main thread may
> exit or detach its mm via use_mm(), but other threads may still
> have a valid mm.
>=20
> To catch this we use find_lock_task_mm(), which walks up all
> threads and returns an appropriate task (with task lock held).
>=20
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Acked-by: Richard Weinberger <richard@nod.at>

Thanks,
//richard


--------------enig88EC09FADEB6B6709009C1CF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJPbawWAAoJEN9758yqZn9e/icH/iVN9aQ0/yXa9SJlm4SLtuzl
ihg243HbKaJpRbPXf+fqsEVutMgRKM+yqkVmeuTdeADDdVSoyoBb750N1fPvq7pU
yjTzeNfWySr727F6cMgblhtKzilRd6JOq+lI3JD74T/pga6mrlIE8Os8fp6HOyfR
sIyklQPPtXml4b1CboiWWwc8qlHSX+2I5w2pCcOSUozsFa8rPBdvtxiXVES0OdJJ
ZFcw2OICs2DbRRJXrq1PCx/qU6e9b3kb5Mj/peSQosjIltksQNafKECm6tonM8TN
e4ZxUnOXUxaULn9E5C7YnuQdP/0SnmF5jnKYNkNqwNIh+oqDPoVgmKnv7aG49GQ=
=Ic2C
-----END PGP SIGNATURE-----

--------------enig88EC09FADEB6B6709009C1CF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 508688D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 16:43:38 -0500 (EST)
Received: by vxc38 with SMTP id 38so543672vxc.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 13:43:36 -0800 (PST)
Date: Wed, 2 Mar 2011 16:43:30 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCHv2 00/24] Refactor sys_swapon
Message-ID: <20110302214330.GC2864@mgebm.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JgQwtEuHJzHdouWu"
Content-Disposition: inline
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org


--JgQwtEuHJzHdouWu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 01 Mar 2011, Cesar Eduardo Barros wrote:

> This patch series refactors the sys_swapon function.
>=20
> sys_swapon is currently a very large function, with 313 lines (more than
> 12 25-line screens), which can make it a bit hard to read. This patch
> series reduces this size by half, by extracting large chunks of related
> code to new helper functions.
>=20
> One of these chunks of code was nearly identical to the part of
> sys_swapoff which is used in case of a failure return from
> try_to_unuse(), so this patch series also makes both share the same
> code.
>=20
> As a side effect of all this refactoring, the compiled code gets a bit
> smaller (from v1 of this patch series):
>=20
>    text       data        bss        dec        hex    filename
>   14012        944        276      15232       3b80    mm/swapfile.o.befo=
re
>   13941        944        276      15161       3b39    mm/swapfile.o.after
>=20
> The v1 of this patch series was lightly tested on a x86_64 VM.
>=20
> Changes from v1:
>   Rebased from v2.6.38-rc4 to v2.6.38-rc7.

Aside from my preference to avoid likely/unlikely unless necessary, I don't
see any problems with this series.

Acked-by: Eric B Munson <emunson@mgebm.net>

For the entire series

--JgQwtEuHJzHdouWu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNbroCAAoJEH65iIruGRnNvH0IALtSyAowcUb+bTdDfocGyfcG
jYECrbb43H/i6iFR0Bop6ILcohbQ/Jc8F9eahLMvropj2hL5LwAk79K8neu1YQuK
4Fg2hhkUEpeapWfzOcTP1ndBlPnfSwdUVgv2A38cm9Hpc/uSV+7BT3gsyNPYGUCA
3oh3usYO+4YP6e4zsSBmRaiiAjZXR45M5KhwWcyi88CAzdZudRUsbRpKEhB2WLsC
auvJ/hsxHXDwBEXzpkuo5HvZIo71JQhb75A6aHw7QKMx8rEaYbJleLjWhE8xQagN
NUWSLlGoneoSBx0xNBUK+jeqJm4wWjhDjP7Ze2ILrMFhQFPsJQOcDct8C+4BdxA=
=of8u
-----END PGP SIGNATURE-----

--JgQwtEuHJzHdouWu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

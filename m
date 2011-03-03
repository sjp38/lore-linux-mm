Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E66C78D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:16:04 -0500 (EST)
Received: by vxc38 with SMTP id 38so1508194vxc.14
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 08:15:57 -0800 (PST)
Date: Thu, 3 Mar 2011 11:15:50 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCHv2 00/24] Refactor sys_swapon
Message-ID: <20110303161550.GA4095@mgebm.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Content-Disposition: inline
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org


--HlL+5n6rz5pIUxbD
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

One more small suggestion, you should cc LKML on this series, as well as any
of the other emails suggested by get_maintainer.pl.

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNb762AAoJEH65iIruGRnN8aQIANvrE9ztWcgLLyTVnb9RND9R
jlmWlbEnZkSTZTY6kaRKk+gHp5E+a/3c7m0l0WXLGEiWPVjoeWs+ra1z6wQsAquO
m0WI17k0lk4dHp2ZJiht8yMR6iIW+RaOTsPe4CXfwa1qlAPCCd3FBkjicUoconpy
HS/V8NELl7UN88whn4IS8WayS/f7LZ06E4SZUl+L0+kVzgZJqYrdjT5QQhKznx/4
7w2aX8KGRNhxkgXOslrRG5uY4Ge03C6Qh3gdSc+beE9NHYIjOROUGHz6tfFoaVFp
5LfneJ8OQ+wtEYAJZ+UacPH+96j3hE29E3Szz54MrwqGESglybDRUQtvaupZcVI=
=ArhI
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 770748D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 16:06:28 -0500 (EST)
Received: by vxc38 with SMTP id 38so500005vxc.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 13:06:10 -0800 (PST)
Date: Wed, 2 Mar 2011 16:06:04 -0500
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCHv2 00/24] Refactor sys_swapon
Message-ID: <20110302210604.GA2864@mgebm.net>
References: <4D6D7FEA.80800@cesarb.net>
 <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Content-Disposition: inline
In-Reply-To: <1299022128-6239-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org


--7AUc2qLy4jB3hD7Z
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

I have tested this set on x86_64 by manually adding/removing swap files and
partitions.  Also I used the hugeadm program (fomr libhugetlbfs) to add
temporary swap files on disk and using ram disks.  All of this worked well.

Tested-by: Eric B Munson <emunson@mgebm.net>

This can be applied to the entire set.

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNbrE8AAoJEH65iIruGRnNz4cIAMlgMbMGSwSvYRgQq8UmsfeU
/qAdeg6dY6nRcVB+IK+sB60UvZy43VLriuG/dXVG83zQHwDt5K3Q++/8UClltTk7
PKmui1q0nza/XE8lBxTd8PTZOeOvOZNHQTn5C8nVyi/MaOeTDULMZMLiH1Dc2AHh
qv1DddekvJ24EKk9q/PyxwMUckgguBhmWOwwH6hFbTiYkIu8C7XjfDBMVbNBlqeN
6c4EX6Ax0LB9yyUZj05U2APPnoRclXbRXmknfhUWiUE5YRAGUUktn4Ljt0Rl3hS2
GASGAh7oFIGwy3waP7cr/pACB0tc9o4gPW2dXz7P9y2hWx341Xotr89HmeXRNaE=
=xGfR
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BDB4B90023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 20:06:40 -0400 (EDT)
Subject: Re: [BUG?] numa required on x86_64?
From: Ian Kumlien <pomac@vapor.com>
Reply-To: pomac@vapor.com
In-Reply-To: <20110624152310.10803ffa.randy.dunlap@oracle.com>
References: <1308952859.25830.8.camel@pi>
	 <20110624152310.10803ffa.randy.dunlap@oracle.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-h7st1+Nmvgs54S/9jjpo"
Date: Sat, 25 Jun 2011 02:06:32 +0200
Message-ID: <1308960392.25830.11.camel@pi>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--=-h7st1+Nmvgs54S/9jjpo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On fre, 2011-06-24 at 15:23 -0700, Randy Dunlap wrote:
> On Sat, 25 Jun 2011 00:00:58 +0200 Ian Kumlien wrote:
>=20
> > Hi all,
> >=20
> > Just found this when wanting to play with development kernels again.
> > Since there is no -gitXX snapshots anymore, I cloned the git =3D)...
> >=20
> > But, it failed to build properly with my config:
> >=20
> > mm/page_cgroup.c line 308: node_start_pfn and node_end_pfn is only
> > defined under NUMA on x86_64.
> >=20
> > The commit that changed the use of this was introduced recently while
> > the mmzone_64.h hasn't been changed since april.
>=20
> You should have cc-ed the commit Author (I did so).

Sorry, tired and i was upgrading systems at work when i found this =3D)

> > commit 37573e8c718277103f61f03741bdc5606d31b07e
> > Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date:   Wed Jun 15 15:08:42 2011 -0700
> >=20
> >     memcg: fix init_page_cgroup nid with sparsemem
> >    =20
> >     Commit 21a3c9646873 ("memcg: allocate memory cgroup structures in l=
ocal
> >     nodes") makes page_cgroup allocation as NUMA aware.  But that cause=
d a
> >     problem https://bugzilla.kernel.org/show_bug.cgi?id=3D36192.
> >    =20
> >     The problem was getting a NID from invalid struct pages, which was =
not
> >     initialized because it was out-of-node, out of [node_start_pfn,
> >     node_end_pfn)
> >    =20
> >     Now, with sparsemem, page_cgroup_init scans pfn from 0 to max_pfn. =
 But
> >     this may scan a pfn which is not on any node and can access memmap =
which
> >     is not initialized.
> >    =20
> >     This makes page_cgroup_init() for SPARSEMEM node aware and remove a=
 code
> >     to get nid from page->flags.  (Then, we'll use valid NID always.)
> >    =20
> >     [akpm@linux-foundation.org: try to fix up comments]
> >     Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>=20
> A patch for this has been posted at least 2 times.
> It's here:  http://marc.info/?l=3Dlinux-mm&m=3D130827204306775&w=3D2
>=20
> Andrew, please merge this (^that^) patch.

Damn, i haven't been following LKML that closely recently =3D/

> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code =
***

--=20
Ian Kumlien  -- http://demius.net || http://pomac.netswarm.net

--=-h7st1+Nmvgs54S/9jjpo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEABECAAYFAk4FJogACgkQ7F3Euyc51N/pPQCfehRQFGW4DPOtvWqZ/87AugI2
MjcAmwVtU4FgC20g0AzwqFPID45PZLpq
=FBsY
-----END PGP SIGNATURE-----

--=-h7st1+Nmvgs54S/9jjpo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

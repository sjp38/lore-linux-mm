Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C19EE6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:35:27 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so1226818pde.12
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:35:27 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id db3si1404663pbc.359.2014.04.23.15.35.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Apr 2014 15:35:26 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:35:15 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 5/4] ipc,shm: minor cleanups
Message-Id: <20140424083515.b113760f062072e69d1899ac@canb.auug.org.au>
In-Reply-To: <20140423152755.7f323cfd0e6901a2907afca8@linux-foundation.org>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	<1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
	<53574AA5.1060205@gmail.com>
	<1398230745.27667.2.camel@buesod1.americas.hpqcorp.net>
	<20140423152755.7f323cfd0e6901a2907afca8@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__24_Apr_2014_08_35_15_+1000_wcig3Jp=HffsP76."
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

--Signature=_Thu__24_Apr_2014_08_35_15_+1000_wcig3Jp=HffsP76.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 23 Apr 2014 15:27:55 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> On Tue, 22 Apr 2014 22:25:45 -0700 Davidlohr Bueso <davidlohr@hp.com> wro=
te:
>=20
> > On Wed, 2014-04-23 at 07:07 +0200, Michael Kerrisk (man-pages) wrote:
> > > On 04/23/2014 04:53 AM, Davidlohr Bueso wrote:
> > > > -  Breakup long function names/args.
> > > > -  Cleaup variable declaration.
> > > > -  s/current->mm/mm
> > > >=20
> > > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > > > ---
> > > >  ipc/shm.c | 40 +++++++++++++++++-----------------------
> > > >  1 file changed, 17 insertions(+), 23 deletions(-)
> > > >=20
> > > > diff --git a/ipc/shm.c b/ipc/shm.c
> > > > index f000696..584d02e 100644
> > > > --- a/ipc/shm.c
> > > > +++ b/ipc/shm.c
> > > > @@ -480,15 +480,13 @@ static const struct vm_operations_struct shm_=
vm_ops =3D {
> > > >  static int newseg(struct ipc_namespace *ns, struct ipc_params *par=
ams)
> > > >  {
> > > >  	key_t key =3D params->key;
> > > > -	int shmflg =3D params->flg;
> > > > +	int id, error, shmflg =3D params->flg;
> > >=20
> > > It's largely a matter of taste (and I may be in a minority), and I kn=
ow
> > > there's certainly precedent in the kernel code, but I don't much like=
 the=20
> > > style of mixing variable declarations that have initializers, with ot=
her
> > > unrelated declarations (e.g., variables without initializers). What i=
s=20
> > > the gain? One less line of text? That's (IMO) more than offset by the=
=20
> > > small loss of readability.
> >=20
> > Yes, it's taste. And yes, your in the minority, at least in many core
> > kernel components and ipc.
>=20
> I'm with Michael.
>=20
> - Putting multiple definitions on the same line (whether or not they
>   are initialized there) makes it impossible to add little comments
>   documenting them.  And we need more little comments documenting
>   locals.
>=20
> - Having multiple definitions on the same line is maddening when the
>   time comes to resolve patch conflicts.  And it increases the
>   likelihood of conflicts in the first place.
>=20
> - It makes it much harder to *find* a definition.

And it changes a line that has nothing to do with the patch.

Sometimes the minority are right :-)
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__24_Apr_2014_08_35_15_+1000_wcig3Jp=HffsP76.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTWEApAAoJEMDTa8Ir7ZwVh5MP/AjyWRpF1vz5tM8Xy0uStunV
+sWsjHOtwRV3FoSoVtFMFhrUVT3wGE4eBy8VIIdSPyk+sfUQ3JRRUCl49Sdy29A8
S2PMPZpqCFaKjNs0P/K+0lFIoq/GHROwFQsgyZtCmEpLGHP4Yc3mZGMwugbosy7I
fpdJcYBG63GbHrkadTp7OnL5tKb604isrkGr1tDw9VYiOovlq/u3huXX8QAX/zqB
Z65QBQy8R/CzAVD6I6VfVCXWwZ54obPbF3sjmq0IH7cjrY/wi9FB+LIDBPckyHR1
0ca0hDmSn0MB+OWAPeJJgrq7p0v3MjxQdzAcfiRznR/GKBlP1t7cYEiqDJl+DhaB
D876joQXDoUqkxclT42LbR0vyCUy6SRMNPvXWZz/XrS6JA9Gssi2cgDgCu1NbvP5
p1MPZPXO4Tnk4iqFezp09U7QAY0gUat742b9dv8jyKozupYkEzpkduZfTei6S5kJ
PZn0ykE32RAWNo2Js16thsfyYHXFEqjpv70l/MIfnjJ5BEidxYOz0GXmc/vDy/iq
ixFXmTZhWeC+uPoudUf7fBzPLFcxs1M1HBxPhwFZw//A3Kq54Y5Ls+etPJ922s3j
ftCgIEGgac/CiUbVLRogIYCfs2rzs29EvFZEyy/TPm627onH/yeAOcnuOrT/ClHG
nXbrJfzMpgXzC5/plvbd
=18lG
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Apr_2014_08_35_15_+1000_wcig3Jp=HffsP76.--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

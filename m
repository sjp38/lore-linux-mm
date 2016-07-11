Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7877E6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:13:39 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id a5so253172969vkc.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:13:39 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id d43si1849975qtc.61.2016.07.11.07.13.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 07:13:38 -0700 (PDT)
Message-ID: <1468246371.13253.63.camel@surriel.com>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
From: Rik van Riel <riel@surriel.com>
Date: Mon, 11 Jul 2016 10:12:51 -0400
In-Reply-To: <20160711063730.GA5284@dhcp22.suse.cz>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
	 <20160711063730.GA5284@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-hJHjyUrk0GF1qSA3pRx+"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


--=-hJHjyUrk0GF1qSA3pRx+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-07-11 at 08:37 +0200, Michal Hocko wrote:
> On Sat 09-07-16 04:43:31, Janani Ravichandran wrote:
> > Struct shrinker does not have a field to uniquely identify the
> > shrinkers
> > it represents. It would be helpful to have a new field to hold
> > names of
> > shrinkers. This information would be useful while analyzing their
> > behavior using tracepoints.
>=20
> This will however increase the vmlinux size even when no tracing is
> enabled. Why cannot we simply print the name of the shrinker
> callbacks?

What mechanism do you have in mind for obtaining the name,
Michal?

> > ---
> > =C2=A0include/linux/shrinker.h | 1 +
> > =C2=A01 file changed, 1 insertion(+)
> >=20
> > diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> > index 4fcacd9..431125c 100644
> > --- a/include/linux/shrinker.h
> > +++ b/include/linux/shrinker.h
> > @@ -52,6 +52,7 @@ struct shrinker {
> > =C2=A0	unsigned long (*scan_objects)(struct shrinker *,
> > =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct shrink_control *sc=
);
> > =C2=A0
> > +	const char *name;
> > =C2=A0	int seeks;	/* seeks to recreate an obj */
> > =C2=A0	long batch;	/* reclaim batch size, 0 =3D default */
> > =C2=A0	unsigned long flags;
> > --=C2=A0
> > 2.7.0
> >=20
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.=C2=A0=C2=A0For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
--=20

All Rights Reversed.
--=-hJHjyUrk0GF1qSA3pRx+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXg6ljAAoJEM553pKExN6Dv3UH/R04G/yua5ZPtP3ZAwqMQzvB
4L28V5spWYgZ43C/MqJu+U54G2RVDFHg8J+LTlyDSLNZ4zLvzMIe+Fwve6xPU8KQ
mvAgKOiUdDqQnXYQHg4DDcMoI6yHKIO0DLBY4EVPPLt0K76bqErSJcIC8NU1O+9+
JtSWGVttRSYmWCyrRyEGAD2gFk8Ht26TYzn4Ep1JyffmgDm4t2nDjbbWMXUnSjoi
6N9xsuPKgcvqKZYO5ugWaWCN+2tgR/zth5/ENIvpJdYSRPPiY6mrPur5kModY01y
sDku0fFN8XSlcNlSM7lmgPtfOo8pvJjFhUNM4YoqVAbav1SOWQo3py1dq4QXOHk=
=xhqp
-----END PGP SIGNATURE-----

--=-hJHjyUrk0GF1qSA3pRx+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

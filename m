Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 566D26B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 15:45:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u25so291748466qtb.3
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 12:45:30 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id s68si13562794qkb.1.2016.07.23.12.45.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 12:45:29 -0700 (PDT)
Message-ID: <1469303017.30053.104.camel@surriel.com>
Subject: Re: [PATCH 1/3] Add a new field to struct shrinker
From: Rik van Riel <riel@surriel.com>
Date: Sat, 23 Jul 2016 15:43:37 -0400
In-Reply-To: <8663a3c5-7b9b-c5b5-cddd-224e97171921@suse.de>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
 <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
 <20160711063730.GA5284@dhcp22.suse.cz>
 <1468246371.13253.63.camel@surriel.com>
 <20160711143342.GN1811@dhcp22.suse.cz>
 <F072D3E2-0514-4A25-868E-2104610EC14A@gmail.com>
 <20160720145405.GP11249@dhcp22.suse.cz>
 <9c67941f-05f0-0d3e-ecc8-dcea60254c8b@suse.de>
	 <8663a3c5-7b9b-c5b5-cddd-224e97171921@suse.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bjOXHgfJAUyzpEltHB1f"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Jones <tonyj@suse.de>, Michal Hocko <mhocko@suse.cz>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


--=-bjOXHgfJAUyzpEltHB1f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-07-22 at 21:05 -0700, Tony Jones wrote:
> On 07/22/2016 06:27 PM, Tony Jones wrote:
> > On 07/20/2016 07:54 AM, Michal Hocko wrote:
> >=20
> > > > Michal, just to make sure I understand you correctly, do you
> > > > mean that we
> > > > could infer the names of the shrinkers by looking at the names
> > > > of their callbacks?
> > >=20
> > > Yes, %ps can then be used for the name of the shrinker structure
> > > (assuming it is available).
> >=20
> > This is fine for emitting via the ftrace /sys interface,=C2=A0=C2=A0but=
 in
> > order to have the data [name] get=C2=A0
> > marshalled thru to perf (for example) you need to add it to the
> > TP_fast_assign entry.
> >=20
> > tony
>=20
> Unfortunately, %ps/%pF doesn't do much (re:=C2=A0=C2=A0Michal's comment
> "assuming it is available"):
>=20
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_printk("%pF %p: nid: %d obj=
ects to shrink %ld gfp_flags %s
> pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan
> %ld",
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0TP_printk("%pF %p(%ps): nid: %=
d objects to shrink %ld
> gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld
> total_scan %ld",
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0__entry->shrink,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0__entry->shr,
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0__entry->shr,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0__entry->nid,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0__entry->nr_objects_to_shrink,
>=20
> # cat trace_pipe
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0b=
ash-1917=C2=A0=C2=A0[003] ...1=C2=A0=C2=A02925.941062: mm_shrink_slab_start=
:
> super_cache_scan+0x0/0x1a0 ffff88042bb60cc0(0xffff88042bb60cc0): nid:
> 0 objects to shrink 0 gfp_flags GFP_KERNEL pgs_scanned 1000 lru_pgs
> 1000 cache items 4 delta 7 total_scan 7
>=20
>=20
> Otherwise what I was suggesting was something like this to ensure it
> was correctly marshaled for perf/etc:
>=20
Janani,

it may make sense to have the code Tony posted be part of
your patch series. Just have both of your Signed-off-by:
lines on that patch.

--=20

All Rights Reversed.
--=-bjOXHgfJAUyzpEltHB1f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXk8jpAAoJEM553pKExN6DMwkH/AqOdHurLUD4xUHPyBMjhrJK
5eW0zRBnwc176aDWwYEFbTyKdvPnLyqlKq1+FMd8mFkvFIiQ6rpRkv83kl1ypkTz
pA8/FbKNEGlaErs1VzumYqRotX8dO5xbVemDQ4JHayY8Z67b2woT1vj/vfXFpMt8
BwjfhiWME1wsD7UvPT5TY8qD5PxTLwE5Dl1zr0j9PbO/nNpR4VeIjFjzV0ZzjXZ0
Qg8u/DHxOnVZlllZNPJMU1X9wAkI0JiGyrvklo0ScwTTDpQoJjRc/J9FQBBI5Uvv
4I8HGBIG16YcDjMJ070DQycNTBSvlzDWJ1hO470EHgrQxyZu3SVqNHe+5FX+dKQ=
=/iCO
-----END PGP SIGNATURE-----

--=-bjOXHgfJAUyzpEltHB1f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

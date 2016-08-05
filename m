Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA3D6B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:55:05 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so155581632lfb.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:55:05 -0700 (PDT)
Received: from imgpgp01.kl.imgtec.org (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTPS id s17si8561196wmb.62.2016.08.05.05.02.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 05:02:45 -0700 (PDT)
Date: Fri, 5 Aug 2016 13:02:43 +0100
From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [PATCH 03/34] mm, vmscan: move LRU lists to node
Message-ID: <20160805120243.GI19514@jhogan-linux.le.imgtec.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-4-git-send-email-mgorman@techsingularity.net>
 <CAAG0J9_k3edxDzqpEjt2BqqZXMW4PVj7BNUBAk6TWtw3Zh_oMg@mail.gmail.com>
 <20160805084115.GO2799@techsingularity.net>
 <20160805105256.GH19514@jhogan-linux.le.imgtec.org>
 <20160805115526.GS2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="CxDuMX1Cv2n9FQfo"
Content-Disposition: inline
In-Reply-To: <20160805115526.GS2799@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes
 Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, metag <linux-metag@vger.kernel.org>

--CxDuMX1Cv2n9FQfo
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 05, 2016 at 12:55:26PM +0100, Mel Gorman wrote:
> On Fri, Aug 05, 2016 at 11:52:57AM +0100, James Hogan wrote:
> > > What's surprising is that it worked for the zone stats as it appears
> > > that calling zone_reclaimable() from that context should also have
> > > broken. Did anything change recently that would have avoided the
> > > zone->pageset dereference in zone_reclaimable() before?
> >=20
> > It appears that zone_pcp_init() was already setting zone->pageset to
> > &boot_pageset, via paging_init():
> >=20
>=20
> /me slaps self
>=20
> Of course.
>=20
> > > The easiest option would be to not call show_mem from arch code until
> > > after the pagesets are setup.
> >=20
> > Since no other arches seem to do show_mem earily during boot like metag,
> > and doing so doesn't really add much value, I'm happy to remove it
> > anyway.
> >=20
>=20
> Thanks. Can I assume you'll merge such a patch or should I roll one?

Yep, I'll take care of it.

>=20
> > However could your change break other things and need fixing anyway?
> >=20
>=20
> Not that I'm aware of. There would have to be a node-based stat that has
> meaning that early in boot to have an effect. If one happened to added
> then it would need fixing but until then the complexity is unnecessary.

Okay, thanks for the help,

Cheers
James

--CxDuMX1Cv2n9FQfo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXpIBjAAoJEGwLaZPeOHZ6ByEQAJPHh/rh84UXd+vdhioXMyLi
C49Q12KTCXHIVBPO/R3oCIY/PimluH1yeh8fJ0OB43y8Sh7G0iVg9/qBHf7+vuPQ
NmY0jyK+/moMCABDSTQDD8WQBIZvDDgNOxASgbksy23lW36jro3erCEqt636V/8Y
93q3kJJvZ2eH/Dm7OXFHQeXjVqMRmv8l1KnmxG9RrZvQwp2HsyBgBFKJvM79K8QC
ezvHo5mmBFXECPlhi8+ydiUzqL36Yj6KRLQVRENu5odCop68Cp8FAizFx1MGhH1/
EzMCoUexr2666hnagBpUgZ4STeMWiNtZ1fWDzZxoANHPotwtGAnwebgKsRoyXflj
J1psAu7byHOBtckK136vngOR/Nx1eGt3elSTob7PXUIl4rN1J2B5QImH6pc0jHE2
6TonqH7M/LghTe8OlrsNuCKDsmstonpPnz/8/kiROe9XUtEFqD1ADzrrFz0Z90ON
vC+5kCOzqmU46NBNrtNDn/jZI+4bZkd54QrNVpdoxPJeXinE8I6Vyd4HK2+0Oa8f
hw+BrtmK5leGb5Sbef5LgkifXtOH1vDS8FiL12V5ifJsFEfXtOudlglWRrYhhDLv
kKkuhioZX4qSqMh3z/k8JX5f8/h6rKHcXqNQ6ex+yhh2iiMinMFskbC92Tf/aHBn
yaGEVIMD3kF+dTNx58jQ
=zevg
-----END PGP SIGNATURE-----

--CxDuMX1Cv2n9FQfo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2D46B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 10:34:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so35164152pfd.2
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 07:34:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i9sor2409017pgp.164.2017.06.10.07.33.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Jun 2017 07:33:59 -0700 (PDT)
Date: Sat, 10 Jun 2017 22:33:56 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, memory_hotplug: support movable_node for hotplugable
 nodes
Message-ID: <20170610143356.GA3457@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170608122318.31598-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
In-Reply-To: <20170608122318.31598-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 02:23:18PM +0200, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>movable_node kernel parameter allows to make hotplugable NUMA
>nodes to put all the hotplugable memory into movable zone which
>allows more or less reliable memory hotremove.  At least this
>is the case for the NUMA nodes present during the boot (see
>find_zone_movable_pfns_for_nodes).
>
>This is not the case for the memory hotplug, though.
>
>	echo online > /sys/devices/system/memory/memoryXYZ/status
                                                           ^^^

Hmm, one typo I think

s/status/state/

--=20
Wei Yang
Help you, Help me

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZPANUAAoJEKcLNpZP5cTd+PoQAIysBVztJG/qDN4rqdnACdoY
d7i1S1Lg6Cw8DC7uuCIX0VWA8ilo3sncTDJDySATWR/I5dPY50r4aiSnGxGppXXG
tZx92e/aSR9xMS2X//anMYqkdk5UNKzM5gLvqKlya9TSwBmi4aVEozxsstmLagZT
ccE6NhthYUzy659zpUn/wUiYQmrli1WyJBPNpYHhYpH4AETsvEe6BQgk/rp21UoF
rgwKbigZgWLHq0bFuFzB43lll960k9d504Z5tSHW7xr6kQGKocEeTY2hZp5U8hie
z7G5F3w6S2AFQFJwlG0bUE4D91X3gbIRUivI42W4dLF8lthy4nAbjVaOxHSc2Ize
YHgJcUe3+BWZ6/F45o+L7h0rGM+5CfMho3O0IsC81ag9uDdNBYTn8V2h4VcVR9Vd
SjajZhzNwFhAJt9zJMrn6y6NN2apfK7aikwNfBzZc/gXDh9+K5cl0o3NbR3GE6rP
M8YnIEiIMRBlRAUlm2N2lj5/l7iJqwESIpAUUNevQ5FB1atJ5SPSDu9jxajGT9hY
Irn8VI/Gr28oLATeo0tJPJAl6h7q8RZ8H/zOGMn6p+7E9SaN8g1aBDFdLajZmNKC
UTcMylXSJF126+k2dR0BbG+VqmsZMP9TV1OE2j5n9dl8FeXhWh3G6AV5yJmBb1QG
1WqtTf3IR/f14lxscYcT
=C+U6
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

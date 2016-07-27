Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22F176B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:18:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u66so7300274qkf.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:18:22 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [74.92.59.67])
        by mx.google.com with ESMTPS id c126si5104064qka.197.2016.07.27.11.18.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 11:18:21 -0700 (PDT)
Message-ID: <1469643382.10218.20.camel@surriel.com>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
From: Rik van Riel <riel@surriel.com>
Date: Wed, 27 Jul 2016 14:16:22 -0400
In-Reply-To: <20160727163351.GC21859@dhcp22.suse.cz>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	 <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
	 <20160727163351.GC21859@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-MPEPp94MKN/tlT2293YM"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org


--=-MPEPp94MKN/tlT2293YM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-07-27 at 18:33 +0200, Michal Hocko wrote:
> On Wed 27-07-16 10:47:59, Janani Ravichandran wrote:
> >=20
> > Add tracepoints to the slowpath code to gather some information.
> > The tracepoints can also be used to find out how much time was
> > spent in
> > the slowpath.
> I do not think this is a right thing to measure.
> __alloc_pages_slowpath
> is more a code organization thing. The fast path might perform an
> expensive operations like zone reclaim (if node_reclaim_mode > 0) so
> these trace point would miss it.

It doesn't look like it does. The fast path either
returns an allocated page to the caller, or calls
into the slow path.

Starting measurement from the slow path cuts out
a lot of noise, since the fast path will never be
slow (and not interesting as a source of memory
allocation latency).

As for the function tracer, I wish I had known
about that!

That looks like it should provide the info that
Janani needs to write her memory allocation latency
tracing script/tool.

As her Outreachy mentor, I should probably apologize
for potentially having sent her down the wrong path
with tracepoints, and I hope it has been an
educational trip at least :)

--=20
All rights reversed

--=-MPEPp94MKN/tlT2293YM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXmPp3AAoJEM553pKExN6D82oH/2L/ndRhjGCoo9OQZkf210Fy
GOpBA5ivHRSofJZ8TawHRZd6tTXAskqfaSVhtyibv+npJkAekizphtj0r0D+F5Hk
ST7xVhb10LZZMJFeypgyQk+LK0T6qH3ABSXc6ilsEjW+i750BDcfaw8VEupUdvw8
8ph0W7uxUQKbcc7pUa3yBbZyLfX8DdCpbzgQnQL03CThJZX4Q+/OZ5HPLOP01N/+
pZL4g/U3DDj1Ox4G3yqjEtAe0I+EZJdoA9ikXLBYf1auGjty9olLPv21DN+Aur+T
40xUDJuoHMEH5QD6U7KHzaHqtKIekf5C96Pf427eRMIzEo3k/X/GIb1gQR90Hr8=
=nerz
-----END PGP SIGNATURE-----

--=-MPEPp94MKN/tlT2293YM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 369F46B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 14:29:59 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id r9so56197293ywg.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 11:29:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 140si2392591qkh.46.2016.08.30.11.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 11:29:58 -0700 (PDT)
Message-ID: <1472581792.10218.52.camel@redhat.com>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages
 in swap cache
From: Rik van Riel <riel@redhat.com>
Date: Tue, 30 Aug 2016 14:29:52 -0400
In-Reply-To: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-6GL+t+CT3wpTKeyMkMZ6"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>


--=-6GL+t+CT3wpTKeyMkMZ6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-08-30 at 10:28 -0700, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>=20
> File pages use a set of radix tree tags (DIRTY, TOWRITE, WRITEBACK,
> etc.) to accelerate finding the pages with a specific tag in the
> radix
> tree during inode writeback.=C2=A0=C2=A0But for anonymous pages in the sw=
ap
> cache, there is no inode writeback.=C2=A0=C2=A0So there is no need to fin=
d the
> pages with some writeback tags in the radix tree.=C2=A0=C2=A0It is not
> necessary
> to touch radix tree writeback tags for pages in the swap cache.
>=20
> Per Rik van Riel's suggestion, a new flag AS_NO_WRITEBACK_TAGS is
> introduced for address spaces which don't need to update the
> writeback
> tags.=C2=A0=C2=A0The flag is set for swap caches.=C2=A0=C2=A0It may be us=
ed for DAX file
> systems, etc.
>=20
> With this patch, the swap out bandwidth improved 22.3% (from ~1.2GB/s
> to
> ~ 1.48GBps) in the vm-scalability swap-w-seq test case with 8
> processes.
> The test is done on a Xeon E5 v3 system.=C2=A0=C2=A0The swap device used =
is a
> RAM
> simulated PMEM (persistent memory) device.=C2=A0=C2=A0The improvement com=
es
> from
> the reduced contention on the swap cache radix tree lock.=C2=A0=C2=A0To t=
est
> sequential swapping out, the test case uses 8 processes, which
> sequentially allocate and write to the anonymous pages until RAM and
> part of the swap device is used up.
>=20
> Details of comparison is as follow,
>=20
> base=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0base+patch
> ---------------- --------------------------
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0%stddev=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0%change=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0%stddev
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0\=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0\
> =C2=A0=C2=A0=C2=A02506952 =C2=B1=C2=A0=C2=A02%=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0+28.1%=C2=A0=C2=A0=C2=A0=C2=A03212076 =C2=B1=C2=A0=C2=A07%=C2=A0=C2=A0vm=
-
> scalability.throughput
> =C2=A0=C2=A0=C2=A01207402 =C2=B1=C2=A0=C2=A07%=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0+22.3%=C2=A0=C2=A0=C2=A0=C2=A01476578 =C2=B1=C2=A0=C2=A06%=C2=A0=C2=A0vm=
stat.swap.so
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A010.86 =C2=B1 12%=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0-23.4%=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A08.31 =C2=B1 16%=C2=A0=C2=
=A0perf-profile.cycles-
> pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_sw
> ap.shrink_page_list
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A010.82 =C2=B1 13%=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0-33.1%=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A07.24 =C2=B1 14%=C2=A0=C2=
=A0perf-profile.cycles-
> pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_in
> active_list.shrink_zone_memcg
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A010.36 =C2=B1 11%=C2=A0=C2=A0=C2=A0=C2=A0-10=
0.0%=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00.00 =C2=B1 -1%=C2=A0=C2=A0pe=
rf-profile.cycles-
> pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page._
> _swap_writepage.swap_writepage
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A010.52 =C2=B1 12%=C2=A0=C2=A0=C2=A0=C2=A0-10=
0.0%=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00.00 =C2=B1 -1%=C2=A0=C2=A0pe=
rf-profile.cycles-
> pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writebac
> k.page_endio.pmem_rw_page
>=20
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shaohua Li <shli@kernel.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>=20
Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed

--=-6GL+t+CT3wpTKeyMkMZ6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXxdChAAoJEM553pKExN6DxRAH/39iO1H9CGaZ6u1uX/WulTFY
aDC1R/bUCbXECp/Ot7JMlV0pOzMZv+N6w2yUoAySG48EpiOO/RX01mDiNA3jhKp8
CI4jN15MaA/A4B+eJhjKpfOwuFdgl9Lb+3d3qXqUll1PTNGkpc1p5bVJgsf374hq
eOgBvsxim534VqK8hDE3u82m5LssWk7lQLzLBcB3YjJM9MY04phJiQh0DA8xMkcC
Jv4w/X755iLdeHUklnsG06vEeX1OJAl9lKTuG7rtcWdnQ9f6axFIS0dUtdpMtSZQ
jh0/OjTwASiFNLhRd4wNsX/hkWAycZV60ZLpoeDhSViqP5x8vARF/ZpbyEyGEsQ=
=vx8K
-----END PGP SIGNATURE-----

--=-6GL+t+CT3wpTKeyMkMZ6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

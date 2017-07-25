Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E24D06B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 17:05:58 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q1so77984687qkb.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:05:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p1si4663617qkb.79.2017.07.25.14.05.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 14:05:58 -0700 (PDT)
Message-ID: <1501016754.26846.22.camel@redhat.com>
Subject: Re: [PATCH -mm -v3 1/6] mm, swap: Add swap cache statistics sysfs
 interface
From: Rik van Riel <riel@redhat.com>
Date: Tue, 25 Jul 2017 17:05:54 -0400
In-Reply-To: <20170725015151.19502-2-ying.huang@intel.com>
References: <20170725015151.19502-1-ying.huang@intel.com>
	 <20170725015151.19502-2-ying.huang@intel.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-INkesESSrJ3PGz9r/mlf"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>


--=-INkesESSrJ3PGz9r/mlf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-07-25 at 09:51 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
>=20
> The swap cache stats could be gotten only via sysrq, which isn't
> convenient in some situation.=C2=A0=C2=A0So the sysfs interface of swap c=
ache
> stats is added for that.=C2=A0=C2=A0The added sysfs directories/files are=
 as
> follow,
>=20
> /sys/kernel/mm/swap
> /sys/kernel/mm/swap/cache_find_total
> /sys/kernel/mm/swap/cache_find_success
> /sys/kernel/mm/swap/cache_add
> /sys/kernel/mm/swap/cache_del
> /sys/kernel/mm/swap/cache_pages
>=20
What is the advantage of this vs new fields in
/proc/vmstat, which is where most of the VM
statistics seem to live?

--=20
All rights reversed
--=-INkesESSrJ3PGz9r/mlf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZd7KyAAoJEM553pKExN6DXxUH/2ogC9QtKGIySHKTSlNUWdvc
cUIDMVKvQUjW0LcxNuHPJlxhkeLSO7pp3REmlgS7jQaTRh4Y2gEhn4nR5Q0+VKTY
Inbmplg1n+avlBkvCkenpeCRGY2amVx19LqKxV/WY7SU6XCY7KhgJWYgduw9B+//
y4hQiSf2XUxtr9iYJ/tY/rsoa+xLaO97yrO/qaP6ai36hceecikuCnCOGBfKP/zW
t3Mjai1gQ56rK2LMTW1eFIrFo3UmqqFR+VIo1/TvNoCMx9VIg9QfcPJWKZ+CdrMX
TidmoF2IKxEA9NjEv9WfYYFmm0qNvKzz/vP6F82CeBvLs3WgGG7xz95vAvzGgBk=
=11TG
-----END PGP SIGNATURE-----

--=-INkesESSrJ3PGz9r/mlf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
